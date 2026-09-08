using DevTools.Domain.Entities;

namespace DevTools.Api.DTOs.Categories;

public record CategoryDto(Guid Id, string Name, string Icon, CategoryType Type, DateTimeOffset CreatedAt)
{
    public static CategoryDto FromDomain(Category category) =>
        new(category.Id, category.Name, category.Icon, category.Type, category.CreatedAt);
}
