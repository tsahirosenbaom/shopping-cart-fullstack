using Microsoft.EntityFrameworkCore;
using ProductApi.Data;
using ProductApi.Models;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Handle circular references
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.WriteIndented = true;
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        });
});

// Add Entity Framework with SQLite
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite("Data Source=products.db"));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

// Initialize database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    
    // Create database
    context.Database.EnsureCreated();
    
    // Seed data if empty
    if (!context.Categories.Any())
    {
        var categories = new List<Category>
        {
            new Category { Name = "Electronics", Description = "Electronic devices and gadgets" },
            new Category { Name = "Clothing", Description = "Apparel and accessories" },
            new Category { Name = "Books", Description = "Books and educational materials" }
        };
        
        context.Categories.AddRange(categories);
        context.SaveChanges();
        
        var electronics = context.Categories.First(c => c.Name == "Electronics");
        var clothing = context.Categories.First(c => c.Name == "Clothing");
        var books = context.Categories.First(c => c.Name == "Books");
        
        var products = new List<Product>
        {
            new Product { Name = "Gaming Laptop", Description = "High-performance gaming laptop", Price = 1299.99m, Stock = 25, CategoryId = electronics.Id },
            new Product { Name = "Wireless Mouse", Description = "Ergonomic wireless mouse", Price = 29.99m, Stock = 100, CategoryId = electronics.Id },
            new Product { Name = "Cotton T-Shirt", Description = "Comfortable cotton t-shirt", Price = 19.99m, Stock = 50, CategoryId = clothing.Id },
            new Product { Name = "Programming Book", Description = "Learn programming fundamentals", Price = 39.99m, Stock = 30, CategoryId = books.Id }
        };
        
        context.Products.AddRange(products);
        context.SaveChanges();
        
        Console.WriteLine("✅ Database seeded with sample data");
    }
}

Console.WriteLine("🚀 API is running at http://localhost:5002");
Console.WriteLine("📚 Swagger docs at http://localhost:5002/swagger");
Console.WriteLine("🔧 JSON serialization cycles handled");

app.Run();
