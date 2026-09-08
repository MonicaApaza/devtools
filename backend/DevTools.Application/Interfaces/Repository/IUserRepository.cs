using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces.Repository;

public interface IUserRepository
{
    Task<User?> GetByUsernameAsync(string username, CancellationToken ct);
    Task AddAsync(User user, CancellationToken ct);
}
