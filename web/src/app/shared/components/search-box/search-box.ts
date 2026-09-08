import { Component, input, model } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-search-box',
  imports: [MatFormFieldModule, MatInputModule, MatIconModule, MatButtonModule],
  template: `
    <mat-form-field appearance="outline" class="search-box">
      <mat-icon matPrefix aria-hidden="true">search</mat-icon>
      <input
        matInput
        [placeholder]="placeholder()"
        [value]="query()"
        (input)="query.set($any($event.target).value)"
      />
      @if (query()) {
        <button matSuffix mat-icon-button type="button" (click)="query.set('')" aria-label="Limpiar búsqueda">
          <mat-icon>close</mat-icon>
        </button>
      }
    </mat-form-field>
  `,
  styles: `
    .search-box {
      width: 100%;
    }
  `,
})
export class SearchBox {
  readonly query = model('');
  readonly placeholder = input('Buscar...');
}
