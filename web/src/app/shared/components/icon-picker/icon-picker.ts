import { Component, model } from '@angular/core';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';

import { ICON_CATALOG } from '../../../core/models/category.model';

@Component({
  selector: 'app-icon-picker',
  imports: [MatChipsModule, MatIconModule],
  template: `
    <mat-chip-listbox [value]="selectedKey()" (change)="selectedKey.set($event.value)">
      @for (entry of iconEntries; track entry[0]) {
        <mat-chip-option [value]="entry[0]">
          <mat-icon aria-hidden="true">{{ entry[1] }}</mat-icon>
        </mat-chip-option>
      }
    </mat-chip-listbox>
  `,
})
export class IconPicker {
  readonly selectedKey = model.required<string>();
  protected readonly iconEntries = Object.entries(ICON_CATALOG);
}
