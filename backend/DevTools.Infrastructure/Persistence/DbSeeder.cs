using DevTools.Application.Interfaces;
using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence;

/// <summary>
/// Seeds one demo user ("monica") plus the same category/shortcut/command
/// catalog the original Flutter app ships, so the app is populated right
/// after the first migration. Only runs once, guarded by an empty-users check.
/// </summary>
public static class DbSeeder
{
    private const string DemoUsername = "monica";
    private const string DemoPassword = "monica123";

    public static async Task SeedAsync(DevToolsDbContext db, IPasswordHasher passwordHasher)
    {
        if (await db.Users.AnyAsync())
        {
            return;
        }

        var user = new User(DemoUsername, passwordHasher.Hash(DemoPassword));
        await db.Users.AddAsync(user);

        var categories = new Dictionary<(string Name, CategoryType Type), Category>();
        void AddCategory(string name, string icon, CategoryType type)
        {
            var category = new Category(name, icon, type, user.Id);
            categories[(name, type)] = category;
        }

        AddCategory("VS Code", "code", CategoryType.Shortcut);
        AddCategory("Android Studio", "developer_mode", CategoryType.Shortcut);
        AddCategory("IntelliJ", "diamond", CategoryType.Shortcut);
        AddCategory("Git", "git", CategoryType.Shortcut);
        AddCategory("Terminal", "terminal", CategoryType.Shortcut);
        AddCategory("Navegador", "browser", CategoryType.Shortcut);
        AddCategory("Flutter", "flutter", CategoryType.Shortcut);
        AddCategory("Git", "git", CategoryType.Command);
        AddCategory("Flutter", "flutter", CategoryType.Command);
        AddCategory("Terminal", "terminal", CategoryType.Command);
        AddCategory("Pub", "pub", CategoryType.Command);

        await db.Categories.AddRangeAsync(categories.Values);

        Guid CategoryId(string name, CategoryType type) => categories[(name, type)].Id;

        var shortcuts = new List<Shortcut>
        {
            new("Paleta de comandos", "Ctrl+Shift+P", null, "editor", CategoryId("VS Code", CategoryType.Shortcut), user.Id),
            new("Buscar en archivos", "Ctrl+Shift+F", null, "busqueda", CategoryId("VS Code", CategoryType.Shortcut), user.Id),
            new("Formatear documento", "Shift+Alt+F", null, "editor", CategoryId("VS Code", CategoryType.Shortcut), user.Id),
            new("Terminal integrada", "Ctrl+`", null, "terminal", CategoryId("VS Code", CategoryType.Shortcut), user.Id),
            new("Buscar en todas partes", "Shift+Shift", null, "busqueda", CategoryId("Android Studio", CategoryType.Shortcut), user.Id),
            new("Reformatear código", "Ctrl+Alt+L", null, "editor", CategoryId("Android Studio", CategoryType.Shortcut), user.Id),
            new("Ejecutar app", "Shift+F10", null, "ejecucion", CategoryId("Android Studio", CategoryType.Shortcut), user.Id),
            new("Generar código", "Alt+Insert", null, "editor", CategoryId("IntelliJ", CategoryType.Shortcut), user.Id),
            new("Navegar a clase", "Ctrl+N", null, "navegacion", CategoryId("IntelliJ", CategoryType.Shortcut), user.Id),
            new("Ver historial", "Ctrl+Shift+H", null, "git", CategoryId("Git", CategoryType.Shortcut), user.Id),
            new("Deshacer cambios", "Ctrl+Z", null, "git", CategoryId("Git", CategoryType.Shortcut), user.Id),
            new("Limpiar pantalla", "Ctrl+L", null, "terminal", CategoryId("Terminal", CategoryType.Shortcut), user.Id),
            new("Buscar en historial", "Ctrl+R", null, "terminal", CategoryId("Terminal", CategoryType.Shortcut), user.Id),
            new("Cancelar comando", "Ctrl+C", null, "terminal", CategoryId("Terminal", CategoryType.Shortcut), user.Id),
            new("Abrir DevTools", "F12", null, "navegador", CategoryId("Navegador", CategoryType.Shortcut), user.Id),
            new("Nueva pestaña", "Ctrl+T", null, "navegador", CategoryId("Navegador", CategoryType.Shortcut), user.Id),
            new("Hot reload", "Ctrl+F5", null, "flutter", CategoryId("Flutter", CategoryType.Shortcut), user.Id),
            new("Hot restart", "Ctrl+Shift+F5", null, "flutter", CategoryId("Flutter", CategoryType.Shortcut), user.Id),
        };
        shortcuts[0].SetFavorite(true);
        shortcuts[6].SetFavorite(true);
        shortcuts[16].SetFavorite(true);
        await db.Shortcuts.AddRangeAsync(shortcuts);

        var commands = new List<Command>
        {
            new("Ver estado del repo", "git status", null, "git", CategoryId("Git", CategoryType.Command), user.Id),
            new("Ver historial de commits", "git log --oneline", null, "git", CategoryId("Git", CategoryType.Command), user.Id),
            new("Crear rama nueva", "git checkout -b", null, "git", CategoryId("Git", CategoryType.Command), user.Id),
            new("Instalar dependencias", "flutter pub get", null, "flutter", CategoryId("Flutter", CategoryType.Command), user.Id),
            new("Analizar código", "flutter analyze", null, "flutter", CategoryId("Flutter", CategoryType.Command), user.Id),
            new("Compilar APK", "flutter build apk --release", null, "flutter", CategoryId("Flutter", CategoryType.Command), user.Id),
            new("Listar archivos", "ls -la", null, "terminal", CategoryId("Terminal", CategoryType.Command), user.Id),
            new("Buscar texto en archivos", "grep -r \"texto\" .", null, "terminal", CategoryId("Terminal", CategoryType.Command), user.Id),
            new("Ver procesos activos", "ps aux", null, "terminal", CategoryId("Terminal", CategoryType.Command), user.Id),
            new("Actualizar paquetes", "dart pub upgrade", null, "pub", CategoryId("Pub", CategoryType.Command), user.Id),
            new("Publicar paquete", "dart pub publish", null, "pub", CategoryId("Pub", CategoryType.Command), user.Id),
            new("Ver paquetes desactualizados", "dart pub outdated", null, "pub", CategoryId("Pub", CategoryType.Command), user.Id),
        };
        commands[0].SetFavorite(true);
        commands[0].IncrementUsage();
        for (var i = 0; i < 4; i++) commands[0].IncrementUsage();
        commands[3].SetFavorite(true);
        for (var i = 0; i < 8; i++) commands[3].IncrementUsage();
        commands[9].SetFavorite(true);
        for (var i = 0; i < 2; i++) commands[9].IncrementUsage();
        await db.Commands.AddRangeAsync(commands);

        await db.SaveChangesAsync();
    }
}
