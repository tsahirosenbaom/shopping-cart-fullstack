using Microsoft.EntityFrameworkCore;
using ProductApi.Data;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp",
        policy =>
        {
            policy.WithOrigins("http://localhost:3000", "https://localhost:3000")
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
});

// Get connection string from AWS Secrets Manager or appsettings
string connectionString;
if (builder.Environment.IsProduction())
{
    var secretsClient = new AmazonSecretsManagerClient();
    var secretName = Environment.GetEnvironmentVariable("SECRET_NAME") ?? "fullstack-app/database/credentials";
    
    try
    {
        var request = new GetSecretValueRequest
        {
            SecretId = secretName
        };
        var response = await secretsClient.GetSecretValueAsync(request);
        var secret = JsonSerializer.Deserialize<Dictionary<string, string>>(response.SecretString);
        
        connectionString = $"Server={secret["host"]},{secret["port"]};Database={secret["dbname"]};User Id={secret["username"]};Password={secret["password"]};TrustServerCertificate=true;Encrypt=true;";
    }
    catch
    {
        connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? 
                          throw new InvalidOperationException("Connection string not found.");
    }
}
else
{
    connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? 
                      throw new InvalidOperationException("Connection string not found.");
}

// Add Entity Framework
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowReactApp");
app.UseAuthorization();
app.MapControllers();

// Auto-migrate database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    context.Database.EnsureCreated();
}

app.Run();
