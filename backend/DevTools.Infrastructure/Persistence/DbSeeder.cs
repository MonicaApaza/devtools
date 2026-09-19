using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence;

/// <summary>
/// Seeds the demo user "Dana" and her catalog of categories, shortcuts and
/// commands by running seed_data.sql (embedded as a resource so it ships
/// with the published app). The script itself deletes and re-inserts Dana's
/// data on every run, so it's safe to execute on each Development startup
/// without duplicating data.
/// </summary>
public static class DbSeeder
{
    private const string ResourceName = "DevTools.Infrastructure.Persistence.seed_data.sql";

    public static async Task SeedAsync(DevToolsDbContext db)
    {
        var assembly = typeof(DbSeeder).Assembly;
        await using var stream = assembly.GetManifestResourceStream(ResourceName)
            ?? throw new InvalidOperationException($"Embedded resource '{ResourceName}' not found.");
        using var reader = new StreamReader(stream);
        var sql = await reader.ReadToEndAsync();

        await db.Database.ExecuteSqlRawAsync(sql);
    }
}
