using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using DevTools.Application.Interfaces;
using DevTools.Domain.Entities;
using DevTools.Infrastructure.Configurations;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace DevTools.Infrastructure.Authentication;

internal class JwtTokenGenerator(IOptions<JwtSettings> jwtOptions) : ITokenGenerator
{
    private readonly JwtSettings _settings = jwtOptions.Value;

    public GeneratedToken GenerateFor(User user)
    {
        var expiresAt = DateTimeOffset.UtcNow.AddDays(_settings.ExpiryDays);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.UniqueName, user.Username),
        };

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Key));
        var credentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: expiresAt.UtcDateTime,
            signingCredentials: credentials);

        return new GeneratedToken(new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
