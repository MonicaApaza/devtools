using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence.Repository;

internal class UserRepository(DevToolsDbContext db) : IUserRepository
{
    public Task<User?> GetByUsernameAsync(string username, CancellationToken ct) =>
        db.Users.FirstOrDefaultAsync(u => u.Username == username, ct);

    public async Task AddAsync(User user, CancellationToken ct) =>
        await db.Users.AddAsync(user, ct);
}
