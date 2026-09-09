import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { MatBottomSheet } from '@angular/material/bottom-sheet';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatMenuModule } from '@angular/material/menu';
import { MatSnackBar } from '@angular/material/snack-bar';
import { firstValueFrom } from 'rxjs';

import { ConfirmDialog } from '../../../shared/components/confirm-dialog/confirm-dialog';
import { CategoryChipFilter } from '../../../shared/components/category-chip-filter/category-chip-filter';
import { EmptyState } from '../../../shared/components/empty-state/empty-state';
import { SearchBox } from '../../../shared/components/search-box/search-box';
import { CategoryService } from '../../../core/services/category';
import { ShortcutService } from '../../../core/services/shortcut';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../../core/models/category.model';
import type { Shortcut } from '../../../core/models/shortcut.model';
import { ShortcutForm } from '../shortcut-form/shortcut-form';

@Component({
  selector: 'app-shortcuts-list',
  imports: [
    MatButtonModule,
    MatCardModule,
    MatChipsModule,
    MatIconModule,
    MatMenuModule,
    SearchBox,
    CategoryChipFilter,
    EmptyState,
  ],
  templateUrl: './shortcuts-list.html',
})
export class ShortcutsList implements OnInit {
  private readonly shortcutService = inject(ShortcutService);
  protected readonly categoryService = inject(CategoryService);
  private readonly bottomSheet = inject(MatBottomSheet);
  private readonly dialog = inject(MatDialog);
  private readonly snackBar = inject(MatSnackBar);

  protected readonly query = signal('');
  protected readonly selectedCategoryId = signal('');
  protected readonly viewMode = signal<'list' | 'grid'>('list');

  protected readonly filtered = computed(() => {
    const q = this.query().trim().toLowerCase();
    const categoryId = this.selectedCategoryId();
    return this.shortcutService.shortcuts().filter((s) => {
      const matchesQuery =
        !q ||
        s.title.toLowerCase().includes(q) ||
        s.keys.toLowerCase().includes(q) ||
        s.tags.some((t) => t.toLowerCase().includes(q));
      const matchesCategory = !categoryId || s.categoryId === categoryId;
      return matchesQuery && matchesCategory;
    });
  });

  async ngOnInit(): Promise<void> {
    await Promise.all([this.shortcutService.load(), this.categoryService.load()]);
  }

  protected categoryName(id: string): string {
    return this.categoryService.findById(id)?.name ?? 'Sin categoría';
  }

  protected categoryIcon(id: string): string {
    const key = this.categoryService.findById(id)?.icon ?? DEFAULT_ICON_KEY;
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  }

  protected splitKeys(keys: string): string[] {
    return keys
      .split('+')
      .map((k) => k.trim())
      .filter(Boolean);
  }

  protected openCreate(): void {
    if (this.categoryService.shortcutCategories().length === 0) {
      this.snackBar.open('Crea al menos una categoría antes de agregar un shortcut.', 'Cerrar', {
        duration: 4000,
      });
      return;
    }
    this.bottomSheet.open(ShortcutForm, { data: {} });
  }

  protected openEdit(shortcut: Shortcut): void {
    this.bottomSheet.open(ShortcutForm, { data: { existing: shortcut } });
  }

  protected async toggleFavorite(shortcut: Shortcut): Promise<void> {
    await this.shortcutService.setFavorite(shortcut.id, !shortcut.isFavorite);
  }

  protected async delete(shortcut: Shortcut): Promise<void> {
    const confirmed = await firstValueFrom(
      this.dialog
        .open(ConfirmDialog, {
          data: { title: 'Eliminar shortcut', message: `¿Eliminar "${shortcut.title}"?` },
        })
        .afterClosed(),
    );
    if (!confirmed) return;

    await this.shortcutService.delete(shortcut.id);
    const ref = this.snackBar.open('Shortcut eliminado', 'Deshacer', { duration: 5000 });
    ref.onAction().subscribe(() => void this.shortcutService.restore(shortcut));
  }
}
