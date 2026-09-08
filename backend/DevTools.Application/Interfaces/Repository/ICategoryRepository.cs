using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces.Repository;

public interface ICategoryRepository
{
    Task<List<Category>> ListAsync(Guid userId, CategoryType type, CancellationToken ct);
    Task<Category?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct);
    Task<bool> ExistsByNameAsync(string name, CategoryType type, Guid userId, Guid? excludeId, CancellationToken ct);
    Task<int> CountShortcutsAsync(Guid categoryId, CancellationToken ct);
    Task<int> CountCommandsAsync(Guid categoryId, CancellationToken ct);
    Task AddAsync(Category category, CancellationToken ct);
    void Remove(Category category);
}
