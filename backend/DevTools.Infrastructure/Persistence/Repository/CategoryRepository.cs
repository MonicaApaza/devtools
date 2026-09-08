using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence.Repository;

internal class CategoryRepository(DevToolsDbContext db) : ICategoryRepository
{
    public Task<List<Category>> ListAsync(Guid userId, CategoryType type, CancellationToken ct) =>
        db.Categories
            .Where(c => c.UserId == userId && (c.Type == type || c.Type == CategoryType.Both))
            .OrderBy(c => c.Name)
            .ToListAsync(ct);

    public Task<Category?> GetByIdAsync(Guid id, Guid userId, CancellationToken ct) =>
        db.Categories.FirstOrDefaultAsync(c => c.Id == id && c.UserId == userId, ct);

    public Task<bool> ExistsByNameAsync(string name, CategoryType type, Guid userId, Guid? excludeId, CancellationToken ct) =>
        db.Categories.AnyAsync(
            c => c.UserId == userId && c.Name == name && c.Type == type && (excludeId == null || c.Id != excludeId),
            ct);

    public Task<int> CountShortcutsAsync(Guid categoryId, CancellationToken ct) =>
        db.Shortcuts.CountAsync(s => s.CategoryId == categoryId, ct);

    public Task<int> CountCommandsAsync(Guid categoryId, CancellationToken ct) =>
        db.Commands.CountAsync(c => c.CategoryId == categoryId, ct);

    public async Task AddAsync(Category category, CancellationToken ct) =>
        await db.Categories.AddAsync(category, ct);

    public void Remove(Category category) => db.Categories.Remove(category);
}
