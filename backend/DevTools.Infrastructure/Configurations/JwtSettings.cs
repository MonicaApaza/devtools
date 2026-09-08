using System.ComponentModel.DataAnnotations;

namespace DevTools.Infrastructure.Configurations;

public class JwtSettings
{
    public const string Section = "Jwt";

    [Required]
    public required string Issuer { get; set; }

    [Required]
    public required string Audience { get; set; }

    [Required, MinLength(32)]
    public required string Key { get; set; }

    [Range(1, 365)]
    public int ExpiryDays { get; set; } = 7;
}
