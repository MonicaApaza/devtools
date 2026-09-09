import { Component, computed, inject, OnInit } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

import { CategoryService } from '../../core/services/category';
import { CommandService } from '../../core/services/command';
import { ShortcutService } from '../../core/services/shortcut';
import type { Category } from '../../core/models/category.model';

interface CategoryCount {
  name: string;
  count: number;
  percentage: number;
}

@Component({
  selector: 'app-statistics',
  imports: [MatCardModule, MatIconModule],
  templateUrl: './statistics.html',
})
export class Statistics implements OnInit {
  private readonly shortcutService = inject(ShortcutService);
  private readonly commandService = inject(CommandService);
  protected readonly categoryService = inject(CategoryService);

  protected readonly totalShortcuts = computed(() => this.shortcutService.shortcuts().length);
  protected readonly totalCommands = computed(() => this.commandService.commands().length);

  protected readonly favoritesCount = computed(
    () =>
      this.shortcutService.shortcuts().filter((s) => s.isFavorite).length +
      this.commandService.commands().filter((c) => c.isFavorite).length,
  );

  protected readonly totalUsage = computed(() =>
    this.commandService.commands().reduce((sum, c) => sum + c.usageCount, 0),
  );

  protected readonly shortcutsByCategory = computed(() =>
    this.countByCategory(this.shortcutService.shortcuts(), this.categoryService.shortcutCategories()),
  );

  protected readonly commandsByCategory = computed(() =>
    this.countByCategory(this.commandService.commands(), this.categoryService.commandCategories()),
  );

  async ngOnInit(): Promise<void> {
    await Promise.all([
      this.shortcutService.load(),
      this.commandService.load(),
      this.categoryService.load(),
    ]);
  }

  private countByCategory(
    items: { categoryId: string }[],
    categories: Category[],
  ): CategoryCount[] {
    const counts = new Map<string, number>();
    for (const item of items) {
      counts.set(item.categoryId, (counts.get(item.categoryId) ?? 0) + 1);
    }

    const max = Math.max(1, ...counts.values());
    return categories
      .map((c) => ({ name: c.name, count: counts.get(c.id) ?? 0, percentage: 0 }))
      .filter((entry) => entry.count > 0)
      .map((entry) => ({ ...entry, percentage: Math.round((entry.count / max) * 100) }))
      .sort((a, b) => b.count - a.count);
  }
}
