using DevTools.Api.DTOs.Categories;
using DevTools.Application.Interfaces;
using DevTools.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DevTools.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/categories")]
public class CategoriesController(ICategoryService categoryService, ICurrentUserService currentUser)
    : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List([FromQuery] CategoryType type, CancellationToken ct)
    {
        var categories = await categoryService.ListAsync(currentUser.UserId, type, ct);
        return Ok(categories.Select(CategoryDto.FromDomain));
    }

    [HttpPost]
    public async Task<IActionResult> Create(CategoryRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var category = await categoryService.CreateAsync(
            currentUser.UserId, request.Name, request.Icon, request.Type ?? CategoryType.Both, ct);
        return StatusCode(StatusCodes.Status201Created, CategoryDto.FromDomain(category));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, CategoryRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var category = await categoryService.UpdateAsync(
            currentUser.UserId, id, request.Name, request.Icon, request.Type ?? CategoryType.Both, ct);
        return Ok(CategoryDto.FromDomain(category));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await categoryService.DeleteAsync(currentUser.UserId, id, ct);
        return NoContent();
    }
}
