import { HttpClient } from '@angular/common/http';
import { Service, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { API_BASE_URL } from '../config/api-config';
import type { Category, CategoryRequest } from '../models/category.model';

@Service()
export class CategoryService {
  private readonly http = inject(HttpClient);

  private readonly shortcutCategoriesSignal = signal<Category[]>([]);
  private readonly commandCategoriesSignal = signal<Category[]>([]);
  readonly shortcutCategories = this.shortcutCategoriesSignal.asReadonly();
  readonly commandCategories = this.commandCategoriesSignal.asReadonly();

  async load(): Promise<void> {
    const [shortcutCategories, commandCategories] = await Promise.all([
      firstValueFrom(
        this.http.get<Category[]>(`${API_BASE_URL}/categories`, { params: { type: 'Shortcut' } }),
      ),
      firstValueFrom(
        this.http.get<Category[]>(`${API_BASE_URL}/categories`, { params: { type: 'Command' } }),
      ),
    ]);
    this.shortcutCategoriesSignal.set(shortcutCategories);
    this.commandCategoriesSignal.set(commandCategories);
  }

  findById(id: string): Category | undefined {
    return (
      this.shortcutCategoriesSignal().find((c) => c.id === id) ??
      this.commandCategoriesSignal().find((c) => c.id === id)
    );
  }

  async create(request: CategoryRequest): Promise<Category> {
    const category = await firstValueFrom(
      this.http.post<Category>(`${API_BASE_URL}/categories`, request),
    );
    await this.load();
    return category;
  }

  async update(id: string, request: CategoryRequest): Promise<Category> {
    const category = await firstValueFrom(
      this.http.put<Category>(`${API_BASE_URL}/categories/${id}`, request),
    );
    await this.load();
    return category;
  }

  async delete(id: string): Promise<void> {
    await firstValueFrom(this.http.delete<void>(`${API_BASE_URL}/categories/${id}`));
    await this.load();
  }
}
