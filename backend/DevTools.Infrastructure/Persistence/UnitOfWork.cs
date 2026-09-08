using DevTools.Application.Interfaces.Repository;

namespace DevTools.Infrastructure.Persistence;

internal class UnitOfWork(DevToolsDbContext db) : IUnitOfWork
{
    public async Task SaveChangesAsync(CancellationToken ct) => await db.SaveChangesAsync(ct);
}
