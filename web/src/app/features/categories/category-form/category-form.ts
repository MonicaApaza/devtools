import { Component, inject, signal } from '@angular/core';
import { FormField, form, required, submit } from '@angular/forms/signals';
import { MatBottomSheetRef, MAT_BOTTOM_SHEET_DATA } from '@angular/material/bottom-sheet';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatRadioModule } from '@angular/material/radio';

import { IconPicker } from '../../../shared/components/icon-picker/icon-picker';
import { CategoryService } from '../../../core/services/category';
import { DEFAULT_ICON_KEY } from '../../../core/models/category.model';
import type { Category, CategoryRequest, CategoryType } from '../../../core/models/category.model';

export interface CategoryFormData {
  existing?: Category;
}

@Component({
  selector: 'app-category-form',
  imports: [
    FormField,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatRadioModule,
    MatProgressSpinnerModule,
    IconPicker,
  ],
  templateUrl: './category-form.html',
  styleUrl: './category-form.scss',
})
export class CategoryForm {
  private readonly bottomSheetRef = inject(MatBottomSheetRef<CategoryForm, boolean>);
  private readonly data = inject<CategoryFormData>(MAT_BOTTOM_SHEET_DATA);
  private readonly categoryService = inject(CategoryService);

  protected readonly isEdit = !!this.data.existing;

  protected readonly model = signal({ name: this.data.existing?.name ?? '' });
  protected readonly textForm = form(this.model, (schema) => {
    required(schema.name, { message: 'Ingresa un nombre' });
  });

  protected readonly icon = signal(this.data.existing?.icon ?? DEFAULT_ICON_KEY);
  // Al crear, se sugiere "Ambos" por defecto (independiente de la pestaña activa);
  // al editar se respeta el tipo ya guardado.
  protected readonly type = signal<CategoryType>(this.data.existing?.type ?? 'Both');

  protected readonly saving = signal(false);
  protected readonly errorMessage = signal('');

  protected onSubmit(): void {
    submit(this.textForm, async () => {
      this.saving.set(true);
      this.errorMessage.set('');
      const request: CategoryRequest = {
        name: this.model().name,
        icon: this.icon(),
        type: this.type(),
      };

      try {
        if (this.data.existing) {
          await this.categoryService.update(this.data.existing.id, request);
        } else {
          await this.categoryService.create(request);
        }
        this.bottomSheetRef.dismiss(true);
      } catch {
        this.errorMessage.set('No se pudo guardar. Puede que el nombre ya exista para este tipo.');
      } finally {
        this.saving.set(false);
      }
    });
  }

  protected cancel(): void {
    this.bottomSheetRef.dismiss(false);
  }
}
