import { Service, signal } from '@angular/core';

const STORAGE_KEY = 'devtools.theme';

function readStoredIsDark(): boolean {
  return localStorage.getItem(STORAGE_KEY) === 'dark';
}

@Service()
export class ThemeService {
  private readonly isDarkSignal = signal(readStoredIsDark());
  readonly isDark = this.isDarkSignal.asReadonly();

  constructor() {
    this.apply(this.isDarkSignal());
  }

  toggle(): void {
    this.set(!this.isDarkSignal());
  }

  set(isDark: boolean): void {
    this.isDarkSignal.set(isDark);
    localStorage.setItem(STORAGE_KEY, isDark ? 'dark' : 'light');
    this.apply(isDark);
  }

  private apply(isDark: boolean): void {
    document.documentElement.classList.toggle('dark-theme', isDark);
  }
}
