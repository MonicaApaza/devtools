using DevTools.Application.Interfaces;
using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using DevTools.Domain.Exceptions;

namespace DevTools.Application.Services;

internal class CategoryService(ICategoryRepository categoryRepository, IUnitOfWork unitOfWork) : ICategoryService
{
    public Task<List<Category>> ListAsync(Guid userId, CategoryType type, CancellationToken ct) =>
        categoryRepository.ListAsync(userId, type, ct);

    public async Task<Category> CreateAsync(
        Guid userId, string name, string icon, CategoryType type, CancellationToken ct)
    {
        if (await categoryRepository.ExistsByNameAsync(name, type, userId, excludeId: null, ct))
        {
            throw new DuplicateCategoryException(name);
        }

        var category = new Category(name, icon, type, userId);
        await categoryRepository.AddAsync(category, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return category;
    }

    public async Task<Category> UpdateAsync(
        Guid userId, Guid id, string name, string icon, CategoryType type, CancellationToken ct)
    {
        var category = await categoryRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CategoryNotFoundException(id);

        if (await categoryRepository.ExistsByNameAsync(name, type, userId, excludeId: id, ct))
        {
            throw new DuplicateCategoryException(name);
        }

        category.Update(name, icon, type);
        await unitOfWork.SaveChangesAsync(ct);
        return category;
    }

    public async Task DeleteAsync(Guid userId, Guid id, CancellationToken ct)
    {
        var category = await categoryRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CategoryNotFoundException(id);

        var shortcutCount = await categoryRepository.CountShortcutsAsync(id, ct);
        var commandCount = await categoryRepository.CountCommandsAsync(id, ct);
        if (shortcutCount > 0 || commandCount > 0)
        {
            throw new CategoryInUseException(shortcutCount, commandCount);
        }

        categoryRepository.Remove(category);
        await unitOfWork.SaveChangesAsync(ct);
    }
}
