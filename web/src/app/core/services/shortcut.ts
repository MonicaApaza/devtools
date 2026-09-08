import { HttpClient } from '@angular/common/http';
import { Service, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { API_BASE_URL } from '../config/api-config';
import type { Shortcut, ShortcutRequest } from '../models/shortcut.model';

@Service()
export class ShortcutService {
  private readonly http = inject(HttpClient);

  private readonly shortcutsSignal = signal<Shortcut[]>([]);
  readonly shortcuts = this.shortcutsSignal.asReadonly();

  async load(): Promise<void> {
    const shortcuts = await firstValueFrom(this.http.get<Shortcut[]>(`${API_BASE_URL}/shortcuts`));
    this.shortcutsSignal.set(shortcuts);
  }

  async create(request: ShortcutRequest): Promise<Shortcut> {
    const shortcut = await firstValueFrom(
      this.http.post<Shortcut>(`${API_BASE_URL}/shortcuts`, request),
    );
    this.shortcutsSignal.update((list) => [shortcut, ...list]);
    return shortcut;
  }

  async update(id: string, request: ShortcutRequest): Promise<Shortcut> {
    const updated = await firstValueFrom(
      this.http.put<Shortcut>(`${API_BASE_URL}/shortcuts/${id}`, request),
    );
    this.shortcutsSignal.update((list) => list.map((s) => (s.id === id ? updated : s)));
    return updated;
  }

  async setFavorite(id: string, isFavorite: boolean): Promise<void> {
    const updated = await firstValueFrom(
      this.http.patch<Shortcut>(`${API_BASE_URL}/shortcuts/${id}/favorite`, { isFavorite }),
    );
    this.shortcutsSignal.update((list) => list.map((s) => (s.id === id ? updated : s)));
  }

  async delete(id: string): Promise<void> {
    await firstValueFrom(this.http.delete<void>(`${API_BASE_URL}/shortcuts/${id}`));
    this.shortcutsSignal.update((list) => list.filter((s) => s.id !== id));
  }

  /** Re-creates a just-deleted shortcut, for the "undo" snackbar action. */
  async restore(shortcut: Shortcut): Promise<void> {
    await this.create({
      title: shortcut.title,
      keys: shortcut.keys,
      description: shortcut.description,
      categoryId: shortcut.categoryId,
      tags: shortcut.tags,
    });
  }
}
