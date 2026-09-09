import { Component, inject, signal } from '@angular/core';
import { MatBottomSheetRef, MAT_BOTTOM_SHEET_DATA } from '@angular/material/bottom-sheet';
import { MatButtonModule } from '@angular/material/button';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatSnackBar } from '@angular/material/snack-bar';

import { CategoryService } from '../../../core/services/category';
import { CommandService } from '../../../core/services/command';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../../core/models/category.model';
import type { Command } from '../../../core/models/command.model';

export interface CommandDetailData {
  command: Command;
}

@Component({
  selector: 'app-command-detail',
  imports: [MatButtonModule, MatIconModule, MatChipsModule],
  templateUrl: './command-detail.html',
})
export class CommandDetail {
  private readonly bottomSheetRef = inject(MatBottomSheetRef<CommandDetail>);
  protected readonly data = inject<CommandDetailData>(MAT_BOTTOM_SHEET_DATA);
  private readonly commandService = inject(CommandService);
  private readonly categoryService = inject(CategoryService);
  private readonly snackBar = inject(MatSnackBar);

  protected readonly usageCount = signal(this.data.command.usageCount);
  protected readonly copying = signal(false);

  protected readonly categoryName =
    this.categoryService.findById(this.data.command.categoryId)?.name ?? 'Sin categoría';
  protected readonly categoryIcon = (() => {
    const key = this.categoryService.findById(this.data.command.categoryId)?.icon ?? DEFAULT_ICON_KEY;
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  })();

  protected async copy(): Promise<void> {
    this.copying.set(true);
    try {
      await navigator.clipboard.writeText(this.data.command.commandText);
      this.usageCount.set(await this.commandService.incrementUsage(this.data.command.id));
      this.snackBar.open('Comando copiado al portapapeles', undefined, { duration: 2000 });
    } finally {
      this.copying.set(false);
    }
  }

  protected close(): void {
    this.bottomSheetRef.dismiss();
  }
}
