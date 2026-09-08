using DevTools.Api.DTOs.Auth;
using DevTools.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace DevTools.Api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await authService.RegisterAsync(request.Username, request.Password, ct);
        return StatusCode(StatusCodes.Status201Created, AuthResponse.FromResult(result));
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request, CancellationToken ct)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var result = await authService.LoginAsync(request.Username, request.Password, ct);
        return Ok(AuthResponse.FromResult(result));
    }
}
