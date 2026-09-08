using DevTools.Application.Interfaces;
using DevTools.Application.Interfaces.Repository;
using DevTools.Domain.Entities;
using DevTools.Domain.Exceptions;

namespace DevTools.Application.Services;

internal class AuthService(
    IUserRepository userRepository,
    IUnitOfWork unitOfWork,
    IPasswordHasher passwordHasher,
    ITokenGenerator tokenGenerator) : IAuthService
{
    public async Task<AuthResult> RegisterAsync(string username, string password, CancellationToken ct)
    {
        var existing = await userRepository.GetByUsernameAsync(username, ct);
        if (existing is not null)
        {
            throw new UsernameTakenException(username);
        }

        var user = new User(username, passwordHasher.Hash(password));
        await userRepository.AddAsync(user, ct);
        await unitOfWork.SaveChangesAsync(ct);

        return BuildResult(user);
    }

    public async Task<AuthResult> LoginAsync(string username, string password, CancellationToken ct)
    {
        var user = await userRepository.GetByUsernameAsync(username, ct);
        if (user is null || !passwordHasher.Verify(password, user.PasswordHash))
        {
            throw new InvalidCredentialsException();
        }

        return BuildResult(user);
    }

    private AuthResult BuildResult(User user)
    {
        var token = tokenGenerator.GenerateFor(user);
        return new AuthResult(user.Id, user.Username, token.Token, token.ExpiresAt);
    }
}
