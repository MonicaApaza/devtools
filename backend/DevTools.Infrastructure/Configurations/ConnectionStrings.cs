using System.ComponentModel.DataAnnotations;

namespace DevTools.Infrastructure.Configurations;

public class ConnectionStrings
{
    public const string Section = "ConnectionStrings";

    [Required]
    public required string DefaultConnection { get; set; }
}
