using DevTools.Domain.Entities;

namespace DevTools.Application.Interfaces;

public record GeneratedToken(string Token, DateTimeOffset ExpiresAt);

public interface ITokenGenerator
{
    GeneratedToken GenerateFor(User user);
}
