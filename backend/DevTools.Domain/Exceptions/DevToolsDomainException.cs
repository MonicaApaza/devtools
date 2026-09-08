namespace DevTools.Domain.Exceptions;

public abstract class DevToolsDomainException : Exception
{
    protected DevToolsDomainException(string message) : base(message)
    {
    }
}
