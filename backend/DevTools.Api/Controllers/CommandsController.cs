using DevTools.Api.DTOs;
using DevTools.Api.DTOs.Commands;
using DevTools.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DevTools.Api.Controllers;

[ApiController]
[Authorize]
[Route("api/commands")]
public class CommandsController(ICommandService commandService, ICurrentUserService currentUser)
    : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> List(CancellationToken ct)
    {
        var commands = await commandService.ListAsync(currentUser.UserId, ct);
        return Ok(commands.Select(CommandDto.FromDomain));
    }

    [HttpPost]
    public async Task<IActionResult> Create(CommandRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var command = await commandService.CreateAsync(
            currentUser.UserId, request.Title, request.CommandText, request.Description, request.Tags,
            request.CategoryId, ct);
        return StatusCode(StatusCodes.Status201Created, CommandDto.FromDomain(command));
    }

    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, CommandRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var command = await commandService.UpdateAsync(
            currentUser.UserId, id, request.Title, request.CommandText, request.Description, request.Tags,
            request.CategoryId, ct);
        return Ok(CommandDto.FromDomain(command));
    }

    [HttpPatch("{id:guid}/favorite")]
    public async Task<IActionResult> SetFavorite(Guid id, FavoriteRequest request, CancellationToken ct)
    {
        var command = await commandService.SetFavoriteAsync(currentUser.UserId, id, request.IsFavorite, ct);
        return Ok(CommandDto.FromDomain(command));
    }

    [HttpPost("{id:guid}/use")]
    public async Task<IActionResult> IncrementUsage(Guid id, CancellationToken ct)
    {
        var command = await commandService.IncrementUsageAsync(currentUser.UserId, id, ct);
        return Ok(CommandUsageDto.FromDomain(command));
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        await commandService.DeleteAsync(currentUser.UserId, id, ct);
        return NoContent();
    }
}
