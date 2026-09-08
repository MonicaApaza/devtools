namespace DevTools.Domain.Exceptions;

public sealed class ShortcutNotFoundException(Guid shortcutId)
    : DevToolsDomainException($"Shortcut '{shortcutId}' was not found.");

public sealed class DuplicateShortcutTitleException(string title)
    : DevToolsDomainException($"A shortcut titled '{title}' already exists.");
