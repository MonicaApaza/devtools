import { inject } from '@angular/core';
import type { CanActivateFn } from '@angular/router';
import { Router } from '@angular/router';

import { AuthService } from '../services/auth';

export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  if (authService.isAuthenticated()) {
    return true;
  }

  return inject(Router).parseUrl('/login');
};
