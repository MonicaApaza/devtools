import { Component, input, model } from '@angular/core';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';

import type { Category } from '../../../core/models/category.model';
import { DEFAULT_ICON_KEY, ICON_CATALOG } from '../../../core/models/category.model';

@Component({
  selector: 'app-category-chip-filter',
  imports: [MatChipsModule, MatIconModule],
  template: `
    <mat-chip-listbox [value]="selectedId()" (change)="selectedId.set($event.value ?? '')">
      <mat-chip-option value="">Todas</mat-chip-option>
      @for (category of categories(); track category.id) {
        <mat-chip-option [value]="category.id">
          <mat-icon matChipAvatar aria-hidden="true">{{ iconFor(category.icon) }}</mat-icon>
          {{ category.name }}
        </mat-chip-option>
      }
    </mat-chip-listbox>
  `,
})
export class CategoryChipFilter {
  readonly categories = input.required<Category[]>();
  readonly selectedId = model('');

  protected iconFor(key: string): string {
    return ICON_CATALOG[key] ?? ICON_CATALOG[DEFAULT_ICON_KEY];
  }
}
