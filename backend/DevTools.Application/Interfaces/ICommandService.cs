using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces;

public interface ICommandService
{
    Task<List<Command>> ListAsync(Guid userId, CancellationToken ct);

    Task<Command> CreateAsync(
        Guid userId, string title, string commandText, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct);

    Task<Command> UpdateAsync(
        Guid userId, Guid id, string title, string commandText, string? description, string[]? tags,
        Guid categoryId, CancellationToken ct);

    Task<Command> SetFavoriteAsync(Guid userId, Guid id, bool isFavorite, CancellationToken ct);

    Task<Command> IncrementUsageAsync(Guid userId, Guid id, CancellationToken ct);

    Task DeleteAsync(Guid userId, Guid id, CancellationToken ct);
}
