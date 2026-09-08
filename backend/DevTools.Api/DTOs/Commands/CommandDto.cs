using DevTools.Domain.Entities;

namespace DevTools.Api.DTOs.Commands;

public record CommandDto(
    Guid Id,
    string Title,
    string CommandText,
    string? Description,
    Guid CategoryId,
    string[] Tags,
    bool IsFavorite,
    int UsageCount,
    DateTimeOffset CreatedAt)
{
    public static CommandDto FromDomain(Command command) => new(
        command.Id,
        command.Title,
        command.CommandText,
        command.Description,
        command.CategoryId,
        command.Tags?.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries) ?? [],
        command.IsFavorite,
        command.UsageCount,
        command.CreatedAt);
}
