import { Component, inject } from '@angular/core';

import { AuthService } from '../../core/services/auth';
import { CategoryService } from '../../core/services/category';

@Component({
  selector: 'app-home',
  template: `<p>Hola, {{ authService.username() }} 👋 (pantalla en construcción)</p>`,
})
export class Home {
  protected readonly authService = inject(AuthService);
  private readonly categoryService = inject(CategoryService);

  constructor() {
    void this.categoryService.load();
  }
}
