import { Component, inject, signal } from '@angular/core';
import { FormField, form, minLength, required, submit } from '@angular/forms/signals';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Router, RouterLink } from '@angular/router';

import { AuthService } from '../../../core/services/auth';

@Component({
  selector: 'app-register',
  imports: [
    FormField,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    MatIconModule,
    MatProgressSpinnerModule,
  ],
  templateUrl: './register.html',
  styleUrl: './register.scss',
})
export class Register {
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly model = signal({ username: '', password: '' });
  protected readonly registerForm = form(this.model, (schema) => {
    required(schema.username, { message: 'Ingresa un usuario' });
    minLength(schema.username, 3, { message: 'Mínimo 3 caracteres' });
    required(schema.password, { message: 'Ingresa una contraseña' });
    minLength(schema.password, 6, { message: 'Mínimo 6 caracteres' });
  });

  protected readonly submitting = signal(false);
  protected readonly errorMessage = signal('');

  protected onSubmit(): void {
    submit(this.registerForm, async () => {
      this.submitting.set(true);
      this.errorMessage.set('');
      try {
        await this.authService.register(this.model());
        await this.router.navigateByUrl('/home');
      } catch {
        this.errorMessage.set('Ese usuario ya existe. Prueba con otro.');
      } finally {
        this.submitting.set(false);
      }
    });
  }
}
