using DevTools.Application.Interfaces;
using DevTools.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace DevTools.Application.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IAuthService, AuthService>();

        return services;
    }
}
