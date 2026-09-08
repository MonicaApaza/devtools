using System.Text;
using DevTools.Api.Middlewares;
using DevTools.Infrastructure.Configurations;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

namespace DevTools.Api.Extensions;

public static class ApiServiceExtensions
{
    private const string FrontendCorsPolicy = "FrontendCorsPolicy";

    public static IServiceCollection AddApiServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddTransient<ExceptionHandlingMiddleware>();

        var jwtSettings = configuration.GetSection(JwtSettings.Section).Get<JwtSettings>()
            ?? throw new InvalidOperationException("Missing Jwt configuration section.");

        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwtSettings.Issuer,
                    ValidateAudience = true,
                    ValidAudience = jwtSettings.Audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.Key)),
                };
            });
        services.AddAuthorization();

        services.AddCors(options => options.AddPolicy(FrontendCorsPolicy, policy =>
            policy.WithOrigins("http://localhost:4200").AllowAnyHeader().AllowAnyMethod()));

        return services;
    }

    public static WebApplication UseApiServices(this WebApplication app)
    {
        app.UseMiddleware<ExceptionHandlingMiddleware>();
        app.UseCors(FrontendCorsPolicy);
        app.UseAuthentication();
        app.UseAuthorization();

        return app;
    }
}
