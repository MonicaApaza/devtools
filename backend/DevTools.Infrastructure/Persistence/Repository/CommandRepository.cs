using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence.Repository;

internal class CommandRepository(DevToolsDbContext db) : ICommandRepository
{
    public Task<List<Command>> ListAsync(Guid userId, CancellationToken ct) =>
        db.Commands.Where(c => c.UserId == userId).OrderByDescending(c => c.CreatedAt).ToListAsync(ct);

    public Task<Command?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct) =>
        db.Commands.FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId, ct);

    public async Task AddAsync(Command command, CancellationToken ct) =>
        await db.Commands.AddAsync(command, ct);

    public void Remove(Command command) => db.Commands.Remove(command);
}
