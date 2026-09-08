using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces.Repository;

public interface ICommandRepository
{
    Task<List<Command>> ListAsync(Guid userId, CancellationToken ct);
    Task<Command?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct);
    Task AddAsync(Command command, CancellationToken ct);
    void Remove(Command command);
}
