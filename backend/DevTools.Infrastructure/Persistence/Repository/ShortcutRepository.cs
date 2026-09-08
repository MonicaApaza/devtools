using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence.Repository;

internal class ShortcutRepository(DevToolsDbContext db) : IShortcutRepository
{
    public Task<List<Shortcut>> ListAsync(Guid userId, CancellationToken ct) =>
        db.Shortcuts.Where(s => s.UserId == userId).OrderByDescending(s => s.CreatedAt).ToListAsync(ct);

    public Task<Shortcut?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct) =>
        db.Shortcuts.FirstOrDefaultAsync(s => s.Id == id && s.UserId == userId, ct);

    public async Task AddAsync(Shortcut shortcut, CancellationToken ct) =>
        await db.Shortcuts.AddAsync(shortcut, ct);

    public void Remove(Shortcut shortcut) => db.Shortcuts.Remove(shortcut);
}
