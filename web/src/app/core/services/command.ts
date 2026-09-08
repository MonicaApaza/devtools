import { HttpClient } from '@angular/common/http';
import { Service, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';

import { API_BASE_URL } from '../config/api-config';
import type { Command, CommandRequest } from '../models/command.model';

@Service()
export class CommandService {
  private readonly http = inject(HttpClient);

  private readonly commandsSignal = signal<Command[]>([]);
  readonly commands = this.commandsSignal.asReadonly();

  async load(): Promise<void> {
    const commands = await firstValueFrom(this.http.get<Command[]>(`${API_BASE_URL}/commands`));
    this.commandsSignal.set(commands);
  }

  async create(request: CommandRequest): Promise<Command> {
    const command = await firstValueFrom(
      this.http.post<Command>(`${API_BASE_URL}/commands`, request),
    );
    this.commandsSignal.update((list) => [command, ...list]);
    return command;
  }

  async update(id: string, request: CommandRequest): Promise<Command> {
    const updated = await firstValueFrom(
      this.http.put<Command>(`${API_BASE_URL}/commands/${id}`, request),
    );
    this.commandsSignal.update((list) => list.map((c) => (c.id === id ? updated : c)));
    return updated;
  }

  async setFavorite(id: string, isFavorite: boolean): Promise<void> {
    const updated = await firstValueFrom(
      this.http.patch<Command>(`${API_BASE_URL}/commands/${id}/favorite`, { isFavorite }),
    );
    this.commandsSignal.update((list) => list.map((c) => (c.id === id ? updated : c)));
  }

  async incrementUsage(id: string): Promise<number> {
    const result = await firstValueFrom(
      this.http.post<{ id: string; usageCount: number }>(`${API_BASE_URL}/commands/${id}/use`, {}),
    );
    this.commandsSignal.update((list) =>
      list.map((c) => (c.id === id ? { ...c, usageCount: result.usageCount } : c)),
    );
    return result.usageCount;
  }

  async delete(id: string): Promise<void> {
    await firstValueFrom(this.http.delete<void>(`${API_BASE_URL}/commands/${id}`));
    this.commandsSignal.update((list) => list.filter((c) => c.id !== id));
  }

  /** Re-creates a just-deleted command, for the "undo" snackbar action. */
  async restore(command: Command): Promise<void> {
    await this.create({
      title: command.title,
      commandText: command.commandText,
      description: command.description,
      categoryId: command.categoryId,
      tags: command.tags,
    });
  }
}
