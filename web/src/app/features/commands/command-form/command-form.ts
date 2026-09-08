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
import { CommandService } from '../../../core/services/command';
import type { Command, CommandRequest } from '../../../core/models/command.model';

export interface CommandFormData {
  existing?: Command;
}

@Component({
  selector: 'app-command-form',
  imports: [
    FormField,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatIconModule,
    MatProgressSpinnerModule,
  ],
  templateUrl: './command-form.html',
  styleUrl: './command-form.scss',
})
export class CommandForm {
  private readonly bottomSheetRef = inject(MatBottomSheetRef<CommandForm, boolean>);
  private readonly data = inject<CommandFormData>(MAT_BOTTOM_SHEET_DATA);
  private readonly commandService = inject(CommandService);
  protected readonly categoryService = inject(CategoryService);

  protected readonly isEdit = !!this.data.existing;

  protected readonly model = signal({
    title: this.data.existing?.title ?? '',
    commandText: this.data.existing?.commandText ?? '',
    description: this.data.existing?.description ?? '',
    tagsText: this.data.existing?.tags.join(', ') ?? '',
  });

  protected readonly textForm = form(this.model, (schema) => {
    required(schema.title, { message: 'Ingresa un título' });
    required(schema.commandText, { message: 'Ingresa el comando' });
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
      const request: CommandRequest = {
        title: value.title,
        commandText: value.commandText,
        description: value.description || null,
        categoryId: this.categoryId(),
        tags: value.tagsText
          .split(',')
          .map((t) => t.trim())
          .filter(Boolean),
      };

      try {
        if (this.data.existing) {
          await this.commandService.update(this.data.existing.id, request);
        } else {
          await this.commandService.create(request);
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
