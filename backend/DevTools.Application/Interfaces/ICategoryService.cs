using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces;

public interface ICategoryService
{
    Task<List<Category>> ListAsync(Guid userId, CategoryType type, CancellationToken ct);

    Task<Category> CreateAsync(Guid userId, string name, string icon, CategoryType type, CancellationToken ct);

    Task<Category> UpdateAsync(
        Guid userId, Guid id, string name, string icon, CategoryType type, CancellationToken ct);

    Task DeleteAsync(Guid userId, Guid id, CancellationToken ct);
}
