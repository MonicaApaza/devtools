using DevTools.Api.DTOs;
using DevTools.Api.DTOs.Shortcuts;
using DevTools.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DevTools.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/shortcuts")]
public class ShortcutsController(IShortcutService shortcutService, ICurrentUserService currentUser)
    : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var shortcuts = await shortcutService.ListAsync(currentUser.UserId, ct);
        return Ok(shortcuts.Select(ShortcutDto.FromDomain));
    }

    [HttpPost]
    public async Task<IActionResult> Create(ShortcutRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var shortcut = await shortcutService.CreateAsync(
            currentUser.UserId, request.Title, request.Keys, request.Description, request.Tags,
            request.CategoryId, ct);
        return StatusCode(StatusCodes.Status201Created, ShortcutDto.FromDomain(shortcut));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, ShortcutRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var shortcut = await shortcutService.UpdateAsync(
            currentUser.UserId, id, request.Title, request.Keys, request.Description, request.Tags,
            request.CategoryId, ct);
        return Ok(ShortcutDto.FromDomain(shortcut));
    }

    [HttpPatch("{id:guid}/favorite")]
    public async Task<IActionResult> SetFavorite(Guid id, FavoriteRequest request, CancellationToken ct)
    {
        var shortcut = await shortcutService.SetFavoriteAsync(currentUser.UserId, id, request.IsFavorite, ct);
        return Ok(ShortcutDto.FromDomain(shortcut));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await shortcutService.DeleteAsync(currentUser.UserId, id, ct);
        return NoContent();
    }
}
