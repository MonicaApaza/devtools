namespace DevTools.Domain.Entities;

public class Command
{
    public Guid Id { get; private set; }
    public string Title { get; private set; }
    public string CommandText { get; private set; }
    public string? Description { get; private set; }
    public string? Tags { get; private set; }
    public bool IsFavorite { get; private set; }
    public int UsageCount { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public Guid CategoryId { get; private set; }
    public Guid UserId { get; private set; }

    private Command()
    {
        Title = string.Empty;
        CommandText = string.Empty;
    }

    public Command(string title, string commandText, string? description, string? tags, Guid categoryId, Guid userId)
    {
        Id = Guid.NewGuid();
        Title = title;
        CommandText = commandText;
        Description = description;
        Tags = tags;
        IsFavorite = false;
        UsageCount = 0;
        CreatedAt = DateTimeOffset.UtcNow;
        CategoryId = categoryId;
        UserId = userId;
    }

    public void Update(string title, string commandText, string? description, string? tags, Guid categoryId)
    {
        Title = title;
        CommandText = commandText;
        Description = description;
        Tags = tags;
        CategoryId = categoryId;
    }

    public void SetFavorite(bool isFavorite) => IsFavorite = isFavorite;

    public void IncrementUsage() => UsageCount++;
}
