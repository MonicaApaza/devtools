import { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, OnInit } from '@angular/core';
import { MatBottomSheet } from '@angular/material/bottom-sheet';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatTabsModule } from '@angular/material/tabs';
import { firstValueFrom } from 'rxjs';

import { ConfirmDialog } from '../../shared/components/confirm-dialog/confirm-dialog';
import { EmptyState } from '../../shared/components/empty-state/empty-state';
import { CategoryService } from '../../core/services/category';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../core/models/category.model';
import type { Category } from '../../core/models/category.model';
import { CategoryForm } from './category-form/category-form';

@Component({
  selector: 'app-categories',
  imports: [MatTabsModule, MatListModule, MatIconModule, MatButtonModule, MatMenuModule, EmptyState],
  templateUrl: './categories.html',
  styleUrl: './categories.scss',
})
export class Categories implements OnInit {
  protected readonly categoryService = inject(CategoryService);
  private readonly bottomSheet = inject(MatBottomSheet);
  private readonly dialog = inject(MatDialog);
  private readonly snackBar = inject(MatSnackBar);

  async ngOnInit(): Promise<void> {
    await this.categoryService.load();
  }

  protected iconFor(key: string): string {
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  }

  protected openCreate(): void {
    this.bottomSheet.open(CategoryForm, { data: {} });
  }

  protected openEdit(category: Category): void {
    this.bottomSheet.open(CategoryForm, { data: { existing: category } });
  }

  protected async delete(category: Category): Promise<void> {
    const confirmed = await firstValueFrom(
      this.dialog
        .open(ConfirmDialog, {
          data: { title: 'Eliminar categoría', message: `¿Eliminar "${category.name}"?` },
        })
        .afterClosed(),
    );
    if (!confirmed) return;

    try {
      await this.categoryService.delete(category.id);
    } catch (err) {
      if (err instanceof HttpErrorResponse && err.status === 409) {
        const body = err.error as { shortcutCount: number; commandCount: number };
        this.snackBar.open(
          `No se puede eliminar: ${body.shortcutCount} shortcut(s) y ${body.commandCount} comando(s) la usan.`,
          'Cerrar',
          { duration: 5000 },
        );
      } else {
        this.snackBar.open('No se pudo eliminar la categoría.', 'Cerrar', { duration: 4000 });
      }
    }
  }
}
