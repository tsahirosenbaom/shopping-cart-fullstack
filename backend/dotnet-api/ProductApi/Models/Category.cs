using System.ComponentModel.DataAnnotations;

namespace ProductApi.Models
{
    public class Category
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(255)]
        public string Name { get; set; } = string.Empty;
        
        public string? Description { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
