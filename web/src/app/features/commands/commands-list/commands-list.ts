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
import { CommandService } from '../../../core/services/command';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../../core/models/category.model';
import type { Command } from '../../../core/models/command.model';
import { CommandDetail } from '../command-detail/command-detail';
import { CommandForm } from '../command-form/command-form';

@Component({
  selector: 'app-commands-list',
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
  templateUrl: './commands-list.html',
})
export class CommandsList implements OnInit {
  private readonly commandService = inject(CommandService);
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
    return this.commandService.commands().filter((c) => {
      const matchesQuery =
        !q ||
        c.title.toLowerCase().includes(q) ||
        c.commandText.toLowerCase().includes(q) ||
        c.tags.some((t) => t.toLowerCase().includes(q));
      const matchesCategory = !categoryId || c.categoryId === categoryId;
      return matchesQuery && matchesCategory;
    });
  });

  async ngOnInit(): Promise<void> {
    await Promise.all([this.commandService.load(), this.categoryService.load()]);
  }

  protected categoryName(id: string): string {
    return this.categoryService.findById(id)?.name ?? 'Sin categoría';
  }

  protected categoryIcon(id: string): string {
    const key = this.categoryService.findById(id)?.icon ?? DEFAULT_ICON_KEY;
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  }

  protected openDetail(command: Command): void {
    this.bottomSheet.open(CommandDetail, { data: { command } });
  }

  protected openCreate(): void {
    if (this.categoryService.commandCategories().length === 0) {
      this.snackBar.open('Crea al menos una categoría antes de agregar un comando.', 'Cerrar', {
        duration: 4000,
      });
      return;
    }
    this.bottomSheet.open(CommandForm, { data: {} });
  }

  protected openEdit(command: Command, event: Event): void {
    event.stopPropagation();
    this.bottomSheet.open(CommandForm, { data: { existing: command } });
  }

  protected async toggleFavorite(command: Command, event: Event): Promise<void> {
    event.stopPropagation();
    await this.commandService.setFavorite(command.id, !command.isFavorite);
  }

  protected async delete(command: Command, event: Event): Promise<void> {
    event.stopPropagation();
    const confirmed = await firstValueFrom(
      this.dialog
        .open(ConfirmDialog, {
          data: { title: 'Eliminar comando', message: `¿Eliminar "${command.title}"?` },
        })
        .afterClosed(),
    );
    if (!confirmed) return;

    await this.commandService.delete(command.id);
    const ref = this.snackBar.open('Comando eliminado', 'Deshacer', { duration: 5000 });
    ref.onAction().subscribe(() => void this.commandService.restore(command));
  }
}
