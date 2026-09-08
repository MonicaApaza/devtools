import { Component, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-empty-state',
  imports: [MatIconModule],
  template: `
    <div class="empty-state">
      <mat-icon aria-hidden="true">{{ icon() }}</mat-icon>
      <p>{{ message() }}</p>
    </div>
  `,
  styles: `
    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      padding: 48px 16px;
      color: var(--mat-sys-outline);
      text-align: center;
    }
    mat-icon {
      font-size: 48px;
      width: 48px;
      height: 48px;
    }
  `,
})
export class EmptyState {
  readonly icon = input('inbox');
  readonly message = input('Nada por aquí todavía.');
}
