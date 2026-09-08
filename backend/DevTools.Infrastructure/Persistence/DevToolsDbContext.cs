using DevTools.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace DevTools.Infrastructure.Persistence;

public class DevToolsDbContext(DbContextOptions<DevToolsDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Shortcut> Shortcuts => Set<Shortcut>();
    public DbSet<Command> Commands => Set<Command>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<User>(entity =>
        {
            entity.Property(u => u.Username).IsRequired().HasMaxLength(50);
            entity.Property(u => u.PasswordHash).IsRequired();
            entity.HasIndex(u => u.Username).IsUnique();
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.Property(c => c.Name).IsRequired().HasMaxLength(80);
            entity.Property(c => c.Icon).IsRequired().HasMaxLength(40);
            entity.Property(c => c.Type).HasConversion<string>().HasMaxLength(20);
            entity.HasIndex(c => new { c.UserId, c.Name, c.Type }).IsUnique();
            entity.HasOne<User>().WithMany().HasForeignKey(c => c.UserId).OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Shortcut>(entity =>
        {
            entity.Property(s => s.Title).IsRequired().HasMaxLength(120);
            entity.Property(s => s.Keys).IsRequired().HasMaxLength(60);
            entity.Property(s => s.Description).HasMaxLength(500);
            entity.Property(s => s.Tags).HasMaxLength(200);
            entity.HasOne<User>().WithMany().HasForeignKey(s => s.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Category>().WithMany().HasForeignKey(s => s.CategoryId).OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Command>(entity =>
        {
            entity.Property(c => c.Title).IsRequired().HasMaxLength(120);
            entity.Property(c => c.CommandText).IsRequired().HasMaxLength(500);
            entity.Property(c => c.Description).HasMaxLength(500);
            entity.Property(c => c.Tags).HasMaxLength(200);
            entity.HasOne<User>().WithMany().HasForeignKey(c => c.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne<Category>().WithMany().HasForeignKey(c => c.CategoryId).OnDelete(DeleteBehavior.Restrict);
        });
    }
}
