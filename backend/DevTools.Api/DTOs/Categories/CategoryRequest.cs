using System.ComponentModel.DataAnnotations;
using DevTools.Domain.Entities;

namespace DevTools.Api.DTOs.Categories;

public class CategoryRequest
{
    [Required, MaxLength(80)]
    public string Name { get; set; } = string.Empty;

    [Required, MaxLength(40)]
    public string Icon { get; set; } = string.Empty;

    /// <summary>Defaults to <see cref="CategoryType.Both"/> when omitted.</summary>
    public CategoryType? Type { get; set; }
}
