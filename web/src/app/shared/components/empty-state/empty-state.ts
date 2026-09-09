import { Component, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-empty-state',
  imports: [MatIconModule],
  template: `
    <div class="flex flex-col items-center gap-2 px-4 py-12 text-center text-outline">
      <mat-icon aria-hidden="true" class="h-12! w-12! text-5xl! leading-none!">{{ icon() }}</mat-icon>
      <p>{{ message() }}</p>
    </div>
  `,
})
export class EmptyState {
  readonly icon = input('inbox');
  readonly message = input('Nada por aquí todavía.');
}
