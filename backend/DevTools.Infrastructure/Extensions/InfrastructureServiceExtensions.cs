using DevTools.Application.Interfaces;
using DevTools.Application.Interfaces.Repository;
using DevTools.Infrastructure.Authentication;
using DevTools.Infrastructure.Configurations;
using DevTools.Infrastructure.Persistence;
using DevTools.Infrastructure.Persistence.Repository;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace DevTools.Infrastructure.Extensions;

public static class InfrastructureServiceExtensions
{
    public static IServiceCollection AddInfrastructureServices(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<ConnectionStrings>()
            .Bind(configuration.GetSection(ConnectionStrings.Section))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        services
            .AddOptions<JwtSettings>()
            .Bind(configuration.GetSection(JwtSettings.Section))
            .ValidateDataAnnotations()
            .ValidateOnStart();

        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Missing ConnectionStrings:DefaultConnection.");

        services.AddDbContext<DevToolsDbContext>(options =>
            options.UseNpgsql(connectionString).UseSnakeCaseNamingConvention());

        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<ITokenGenerator, JwtTokenGenerator>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ICategoryRepository, CategoryRepository>();
        services.AddScoped<IShortcutRepository, ShortcutRepository>();
        services.AddScoped<ICommandRepository, CommandRepository>();
        services.AddScoped<IUnitOfWork, UnitOfWork>();

        return services;
    }
}
