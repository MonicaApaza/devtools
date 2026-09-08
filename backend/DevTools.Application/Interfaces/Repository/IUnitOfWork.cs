namespace DevTools.Application.Interfaces.Repository;

public interface IUnitOfWork
{
    Task SaveChangesAsync(CancellationToken ct);
}
