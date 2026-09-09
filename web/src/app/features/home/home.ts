import { Component, computed, inject, OnInit } from '@angular/core';
import { MatBottomSheet } from '@angular/material/bottom-sheet';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

import { EmptyState } from '../../shared/components/empty-state/empty-state';
import { SearchBox } from '../../shared/components/search-box/search-box';
import { AuthService } from '../../core/services/auth';
import { CategoryService } from '../../core/services/category';
import { CommandService } from '../../core/services/command';
import { SearchStateService } from '../../core/services/search-state';
import { ShortcutService } from '../../core/services/shortcut';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../core/models/category.model';
import type { Command } from '../../core/models/command.model';
import type { Shortcut } from '../../core/models/shortcut.model';
import { CommandDetail } from '../commands/command-detail/command-detail';

interface HomeEntry {
  kind: 'shortcut' | 'command';
  item: Shortcut | Command;
}

@Component({
  selector: 'app-home',
  imports: [MatIconModule, MatCardModule, SearchBox, EmptyState],
  templateUrl: './home.html',
})
export class Home implements OnInit {
  protected readonly authService = inject(AuthService);
  private readonly shortcutService = inject(ShortcutService);
  private readonly commandService = inject(CommandService);
  private readonly categoryService = inject(CategoryService);
  private readonly bottomSheet = inject(MatBottomSheet);

  protected readonly query = inject(SearchStateService).query;

  protected readonly greeting = computed(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  });

  private readonly allEntries = computed<HomeEntry[]>(() => [
    ...this.shortcutService.shortcuts().map((item) => ({ kind: 'shortcut' as const, item })),
    ...this.commandService.commands().map((item) => ({ kind: 'command' as const, item })),
  ]);

  protected readonly favorites = computed(() => {
    const q = this.query().trim().toLowerCase();
    return this.allEntries().filter(
      (entry) => entry.item.isFavorite && (!q || entry.item.title.toLowerCase().includes(q)),
    );
  });

  protected readonly recent = computed(() => {
    const q = this.query().trim().toLowerCase();
    return this.allEntries()
      .filter((entry) => !q || entry.item.title.toLowerCase().includes(q))
      .sort((a, b) => new Date(b.item.createdAt).getTime() - new Date(a.item.createdAt).getTime())
      .slice(0, 8);
  });

  async ngOnInit(): Promise<void> {
    await Promise.all([
      this.shortcutService.load(),
      this.commandService.load(),
      this.categoryService.load(),
    ]);
  }

  protected categoryIcon(id: string): string {
    const key = this.categoryService.findById(id)?.icon ?? DEFAULT_ICON_KEY;
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  }

  protected openEntry(entry: HomeEntry): void {
    if (entry.kind === 'command') {
      this.bottomSheet.open(CommandDetail, { data: { command: entry.item as Command } });
    }
  }
}
