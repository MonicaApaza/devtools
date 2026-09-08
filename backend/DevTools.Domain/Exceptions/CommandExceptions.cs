namespace DevTools.Domain.Exceptions;

public sealed class CommandNotFoundException(Guid commandId)
    : DevToolsDomainException($"Command '{commandId}' was not found.");

public sealed class DuplicateCommandTitleException(string title)
    : DevToolsDomainException($"A command titled '{title}' already exists.");
