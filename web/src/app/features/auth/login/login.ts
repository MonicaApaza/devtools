import { Component, inject, signal } from '@angular/core';
import { FormField, form, required, submit } from '@angular/forms/signals';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Router, RouterLink } from '@angular/router';

import { AuthService } from '../../../core/services/auth';

@Component({
  selector: 'app-login',
  imports: [
    FormField,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatIconModule,
    MatProgressSpinnerModule,
  ],
  templateUrl: './login.html',
  styleUrl: './login.scss',
})
export class Login {
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly model = signal({ username: '', password: '' });
  protected readonly loginForm = form(this.model, (schema) => {
    required(schema.username, { message: 'Ingresa tu usuario' });
    required(schema.password, { message: 'Ingresa tu contraseña' });
  });

  protected readonly submitting = signal(false);
  protected readonly errorMessage = signal('');

  protected onSubmit(): void {
    submit(this.loginForm, async () => {
      this.submitting.set(true);
      this.errorMessage.set('');
      try {
        await this.authService.login(this.model());
        await this.router.navigateByUrl('/home');
      } catch {
        this.errorMessage.set('Usuario o contraseña incorrectos.');
      } finally {
        this.submitting.set(false);
      }
    });
  }
}
