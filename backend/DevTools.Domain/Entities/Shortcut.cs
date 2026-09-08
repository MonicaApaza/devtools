namespace DevTools.Domain.Entities;

public class Shortcut
{
    public Guid Id { get; private set; }
    public string Title { get; private set; }
    public string Keys { get; private set; }
    public string? Description { get; private set; }
    public string? Tags { get; private set; }
    public bool IsFavorite { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public Guid CategoryId { get; private set; }
    public Guid UserId { get; private set; }

    private Shortcut()
    {
        Title = string.Empty;
        Keys = string.Empty;
    }

    public Shortcut(string title, string keys, string? description, string? tags, Guid categoryId, Guid userId)
    {
        Id = Guid.NewGuid();
        Title = title;
        Keys = keys;
        Description = description;
        Tags = tags;
        IsFavorite = false;
        CreatedAt = DateTimeOffset.UtcNow;
        CategoryId = categoryId;
        UserId = userId;
    }

    public void Update(string title, string keys, string? description, string? tags, Guid categoryId)
    {
        Title = title;
        Keys = keys;
        Description = description;
        Tags = tags;
        CategoryId = categoryId;
    }

    public void SetFavorite(bool isFavorite) => IsFavorite = isFavorite;
}
