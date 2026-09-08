using DevTools.Domain.Entities;

namespace DevTools.Api.DTOs.Shortcuts;

public record ShortcutDto(
    Guid Id,
    string Title,
    string Keys,
    string? Description,
    Guid CategoryId,
    string[] Tags,
    bool IsFavorite,
    DateTimeOffset CreatedAt)
{
    public static ShortcutDto FromDomain(Shortcut shortcut) => new(
        shortcut.Id,
        shortcut.Title,
        shortcut.Keys,
        shortcut.Description,
        shortcut.CategoryId,
        shortcut.Tags?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries) ?? [],
        shortcut.IsFavorite,
        shortcut.CreatedAt);
}
