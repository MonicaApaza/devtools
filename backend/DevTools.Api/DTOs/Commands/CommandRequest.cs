using System.ComponentModel.DataAnnotations;

namespace DevTools.Api.DTOs.Commands;

public class CommandRequest
{
    [Required, MaxLength(120)]
    public string Title { get; set; } = string.Empty;

    [Required, MaxLength(500)]
    public string CommandText { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? Description { get; set; }

    [Required]
    public Guid CategoryId { get; set; }

    public string[]? Tags { get; set; }
}
