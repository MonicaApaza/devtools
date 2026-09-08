import type { HttpHandlerFn, HttpRequest } from '@angular/common/http';
import { inject } from '@angular/core';

import { AuthService } from '../services/auth';

export function authInterceptor(req: HttpRequest<unknown>, next: HttpHandlerFn) {
  const token = inject(AuthService).session()?.token;
  if (!token) {
    return next(req);
  }

  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } }));
}
