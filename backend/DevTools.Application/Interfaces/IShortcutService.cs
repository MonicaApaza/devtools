using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces;

public interface IShortcutService
{
    Task<List<Shortcut>> ListAsync(Guid userId, CancellationToken ct);

    Task<Shortcut> CreateAsync(
        Guid userId, string title, string keys, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct);

    Task<Shortcut> UpdateAsync(
        Guid userId, Guid id, string title, string keys, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct);

    Task<Shortcut> SetFavoriteAsync(Guid userId, Guid id, bool isFavorite, CancellationToken ct);

    Task DeleteAsync(Guid userId, Guid id, CancellationToken ct);
}
