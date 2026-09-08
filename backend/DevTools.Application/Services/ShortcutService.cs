using DevTools.Application.Interfaces;
using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using DevTools.Domain.Exceptions;

namespace DevTools.Application.Services;

internal class ShortcutService(
    IShortcutRepository shortcutRepository,
    ICategoryRepository categoryRepository,
    IUnitOfWork unitOfWork) : IShortcutService
{
    public Task<List<Shortcut>> ListAsync(Guid userId, CancellationToken ct) =>
        shortcutRepository.ListAsync(userId, ct);

    public async Task<Shortcut> CreateAsync(
        Guid userId, string title, string keys, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct)
    {
        await EnsureCategoryAppliesAsync(userId, categoryId, CategoryType.Shortcut, ct);

        var shortcut = new Shortcut(title, keys, description, JoinTags(tags), categoryId, userId);
        await shortcutRepository.AddAsync(shortcut, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return shortcut;
    }

    public async Task<Shortcut> UpdateAsync(
        Guid userId, Guid id, string title, string keys, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct)
    {
        var shortcut = await shortcutRepository.GetByIdAsync(id, userId, ct)
            ?? throw new ShortcutNotFoundException(id);

        await EnsureCategoryAppliesAsync(userId, categoryId, CategoryType.Shortcut, ct);

        shortcut.Update(title, keys, description, JoinTags(tags), categoryId);
        await unitOfWork.SaveChangesAsync(ct);
        return shortcut;
    }

    public async Task<Shortcut> SetFavoriteAsync(Guid userId, Guid id, bool isFavorite, CancellationToken ct)
    {
        var shortcut = await shortcutRepository.GetByIdAsync(id, userId, ct)
            ?? throw new ShortcutNotFoundException(id);

        shortcut.SetFavorite(isFavorite);
        await unitOfWork.SaveChangesAsync(ct);
        return shortcut;
    }

    public async Task DeleteAsync(Guid userId, Guid id, CancellationToken ct)
    {
        var shortcut = await shortcutRepository.GetByIdAsync(id, userId, ct)
            ?? throw new ShortcutNotFoundException(id);

        shortcutRepository.Remove(shortcut);
        await unitOfWork.SaveChangesAsync(ct);
    }

    private async Task EnsureCategoryAppliesAsync(
        Guid userId, Guid categoryId, CategoryType requiredType, CancellationToken ct)
    {
        var category = await categoryRepository.GetByIdAsync(categoryId, userId, ct);
        if (category is null || !category.AppliesTo(requiredType))
        {
            throw new CategoryNotFoundException(categoryId);
        }
    }

    private static string? JoinTags(string[]? tags) =>
        tags is null || tags.Length == 0 ? null : string.Join(',', tags);
}
