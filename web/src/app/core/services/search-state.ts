import { Service, effect, signal } from '@angular/core';

const STORAGE_KEY = 'devtools.search';

/**
 * Holds a single search query shared by Home, Shortcuts and Commands, so the
 * text you type on one screen is still there when you switch to another —
 * and survives a page reload within the same tab session.
 */
@Service()
export class SearchStateService {
  readonly query = signal(sessionStorage.getItem(STORAGE_KEY) ?? '');

  constructor() {
    effect(() => sessionStorage.setItem(STORAGE_KEY, this.query()));
  }
}
