namespace DevTools.Domain.Entities;

public class Category
{
    public Guid Id { get; private set; }
    public string Name { get; private set; }
    public string Icon { get; private set; }
    public CategoryType Type { get; private set; }
    public Guid UserId { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }

    private Category()
    {
        Name = string.Empty;
        Icon = string.Empty;
    }

    public Category(string name, string icon, CategoryType type, Guid userId)
    {
        Id = Guid.NewGuid();
        Name = name;
        Icon = icon;
        Type = type;
        UserId = userId;
        CreatedAt = DateTimeOffset.UtcNow;
    }

    public void Update(string name, string icon, CategoryType type)
    {
        Name = name;
        Icon = icon;
        Type = type;
    }

    /// <summary>
    /// Whether this category should appear when listing categories for <paramref name="requestedType"/>
    /// (a category typed "Both" shows up for either Shortcut or Command listings).
    /// </summary>
    public bool AppliesTo(CategoryType requestedType) => Type == requestedType || Type == CategoryType.Both;
}
