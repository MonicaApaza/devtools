import { HttpClient } from '@angular/common/http';
import { Service, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { API_BASE_URL } from '../config/api-config';
import type { AuthSession, LoginRequest, RegisterRequest } from '../models/auth.model';

const STORAGE_KEY = 'devtools.session';

function readStoredSession(): AuthSession | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;

    const session = JSON.parse(raw) as AuthSession;
    if (new Date(session.expiresAt).getTime() <= Date.now()) {
      localStorage.removeItem(STORAGE_KEY);
      return null;
    }
    return session;
  } catch {
    return null;
  }
}

@Service()
export class AuthService {
  private readonly http = inject(HttpClient);

  private readonly sessionSignal = signal<AuthSession | null>(readStoredSession());
  readonly session = this.sessionSignal.asReadonly();
  readonly isAuthenticated = computed(() => this.sessionSignal() !== null);
  readonly username = computed(() => this.sessionSignal()?.username ?? '');

  async login(request: LoginRequest): Promise<void> {
    const session = await firstValueFrom(
      this.http.post<AuthSession>(`${API_BASE_URL}/auth/login`, request),
    );
    this.setSession(session);
  }

  async register(request: RegisterRequest): Promise<void> {
    const session = await firstValueFrom(
      this.http.post<AuthSession>(`${API_BASE_URL}/auth/register`, request),
    );
    this.setSession(session);
  }

  logout(): void {
    localStorage.removeItem(STORAGE_KEY);
    this.sessionSignal.set(null);
  }

  private setSession(session: AuthSession): void {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
    this.sessionSignal.set(session);
  }
}
