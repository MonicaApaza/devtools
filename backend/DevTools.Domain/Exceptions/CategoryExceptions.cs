namespace DevTools.Domain.Exceptions;

public sealed class CategoryNotFoundException(Guid categoryId)
    : DevToolsDomainException($"Category '{categoryId}' was not found.");

public sealed class DuplicateCategoryException(string name)
    : DevToolsDomainException($"A category named '{name}' already exists for this type.");

public sealed class CategoryInUseException(int shortcutCount, int commandCount)
    : DevToolsDomainException(
        $"Category is still referenced by {shortcutCount} shortcut(s) and {commandCount} command(s).")
{
    public int ShortcutCount { get; } = shortcutCount;
    public int CommandCount { get; } = commandCount;
}
