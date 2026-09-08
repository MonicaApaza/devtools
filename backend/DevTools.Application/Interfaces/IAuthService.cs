namespace DevTools.Application.Interfaces;

public record AuthResult(Guid UserId, string Username, string Token, DateTimeOffset ExpiresAt);

public interface IAuthService
{
    Task<AuthResult> RegisterAsync(string username, string password, CancellationToken ct);
    Task<AuthResult> LoginAsync(string username, string password, CancellationToken ct);
}
