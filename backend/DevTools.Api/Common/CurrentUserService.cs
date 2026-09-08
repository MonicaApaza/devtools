using System.Security.Claims;
using DevTools.Application.Interfaces;

namespace DevTools.Api.Common;

internal class CurrentUserService(IHttpContextAccessor httpContextAccessor) : ICurrentUserService
{
    public Guid UserId
    {
        get
        {
            var value = httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new InvalidOperationException("No authenticated user in the current request.");
            return Guid.Parse(value);
        }
    }
}
