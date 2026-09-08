using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces.Repository;

public interface IShortcutRepository
{
    Task<List<Shortcut>> ListAsync(Guid userId, CancellationToken ct);
    Task<Shortcut?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct);
    Task AddAsync(Shortcut shortcut, CancellationToken ct);
    void Remove(Shortcut shortcut);
}
