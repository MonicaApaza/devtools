import { Component, computed, inject, signal } from '@angular/core';
import { FormField, form, required, submit } from '@angular/forms/signals';
import { MatBottomSheetRef, MAT_BOTTOM_SHEET_DATA } from '@angular/material/bottom-sheet';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSelectModule } from '@angular/material/select';

import { CategoryService } from '../../../core/services/category';
import { ShortcutService } from '../../../core/services/shortcut';
import type { Shortcut, ShortcutRequest } from '../../../core/models/shortcut.model';

export interface ShortcutFormData {
  existing?: Shortcut;
}

@Component({
  selector: 'app-shortcut-form',
  imports: [
    FormField,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatIconModule,
    MatProgressSpinnerModule,
  ],
  templateUrl: './shortcut-form.html',
})
export class ShortcutForm {
  private readonly bottomSheetRef = inject(MatBottomSheetRef<ShortcutForm, boolean>);
  private readonly data = inject<ShortcutFormData>(MAT_BOTTOM_SHEET_DATA);
  private readonly shortcutService = inject(ShortcutService);
  protected readonly categoryService = inject(CategoryService);

  protected readonly isEdit = !!this.data.existing;

  protected readonly model = signal({
    title: this.data.existing?.title ?? '',
    keys: this.data.existing?.keys ?? '',
    description: this.data.existing?.description ?? '',
    tagsText: this.data.existing?.tags.join(', ') ?? '',
  });

  protected readonly textForm = form(this.model, (schema) => {
    required(schema.title, { message: 'Ingresa un título' });
    required(schema.keys, { message: 'Ingresa la combinación de teclas' });
  });

  protected readonly categoryId = signal(this.data.existing?.categoryId ?? '');
  protected readonly categoryTouched = signal(false);
  protected readonly categoryError = computed(
    () => this.categoryTouched() && !this.categoryId(),
  );

  protected readonly saving = signal(false);
  protected readonly errorMessage = signal('');

  protected onSubmit(): void {
    this.categoryTouched.set(true);
    if (!this.categoryId()) {
      return;
    }

    submit(this.textForm, async () => {
      this.saving.set(true);
      this.errorMessage.set('');
      const value = this.model();
      const request: ShortcutRequest = {
        title: value.title,
        keys: value.keys,
        description: value.description || null,
        categoryId: this.categoryId(),
        tags: value.tagsText
          .split(',')
          .map((t) => t.trim())
          .filter(Boolean),
      };

      try {
        if (this.data.existing) {
          await this.shortcutService.update(this.data.existing.id, request);
        } else {
          await this.shortcutService.create(request);
        }
        this.bottomSheetRef.dismiss(true);
      } catch {
        this.errorMessage.set('No se pudo guardar. Puede que el título ya exista.');
      } finally {
        this.saving.set(false);
      }
    });
  }

  protected cancel(): void {
    this.bottomSheetRef.dismiss(false);
  }
}
