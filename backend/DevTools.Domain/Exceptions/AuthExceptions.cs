namespace DevTools.Domain.Exceptions;

public sealed class InvalidCredentialsException()
    : DevToolsDomainException("Invalid username or password.");

public sealed class UsernameTakenException(string username)
    : DevToolsDomainException($"Username '{username}' is already taken.");
