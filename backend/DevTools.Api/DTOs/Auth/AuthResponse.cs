using DevTools.Application.Interfaces;

namespace DevTools.Api.DTOs.Auth;

public record AuthResponse(Guid UserId, string Username, string Token, DateTimeOffset ExpiresAt)
{
    public static AuthResponse FromResult(AuthResult result) =>
        new(result.UserId, result.Username, result.Token, result.ExpiresAt);
}
