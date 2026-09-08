using DevTools.Application.Interfaces;
using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using DevTools.Domain.Exceptions;

namespace DevTools.Application.Services;

internal class CommandService(
    ICommandRepository commandRepository,
    ICategoryRepository categoryRepository,
    IUnitOfWork unitOfWork) : ICommandService
{
    public Task<List<Command>> ListAsync(Guid userId, CancellationToken ct) =>
        commandRepository.ListAsync(userId, ct);

    public async Task<Command> CreateAsync(
        Guid userId, string title, string commandText, string? description, string[]? tags, Guid categoryId,
        CancellationToken ct)
    {
        await EnsureCategoryAppliesAsync(userId, categoryId, CategoryType.Command, ct);

        var command = new Command(title, commandText, description, JoinTags(tags), categoryId, userId);
        await commandRepository.AddAsync(command, ct);
        await unitOfWork.SaveChangesAsync(ct);
        return command;
    }

    public async Task<Command> UpdateAsync(
        Guid userId, Guid id, string title, string commandText, string? description, string[]? tags,
        Guid categoryId, CancellationToken ct)
    {
        var command = await commandRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CommandNotFoundException(id);

        await EnsureCategoryAppliesAsync(userId, categoryId, CategoryType.Command, ct);

        command.Update(title, commandText, description, JoinTags(tags), categoryId);
        await unitOfWork.SaveChangesAsync(ct);
        return command;
    }

    public async Task<Command> SetFavoriteAsync(Guid userId, Guid id, bool isFavorite, CancellationToken ct)
    {
        var command = await commandRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CommandNotFoundException(id);

        command.SetFavorite(isFavorite);
        await unitOfWork.SaveChangesAsync(ct);
        return command;
    }

    public async Task<Command> IncrementUsageAsync(Guid userId, Guid id, CancellationToken ct)
    {
        var command = await commandRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CommandNotFoundException(id);

        command.IncrementUsage();
        await unitOfWork.SaveChangesAsync(ct);
        return command;
    }

    public async Task DeleteAsync(Guid userId, Guid id, CancellationToken ct)
    {
        var command = await commandRepository.GetByIdAsync(id, userId, ct)
            ?? throw new CommandNotFoundException(id);

        commandRepository.Remove(command);
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
