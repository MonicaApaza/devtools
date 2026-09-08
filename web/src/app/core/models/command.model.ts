export interface Command {
  id: string;
  title: string;
  commandText: string;
  description: string | null;
  categoryId: string;
  tags: string[];
  isFavorite: boolean;
  usageCount: number;
  createdAt: string;
}

export interface CommandRequest {
  title: string;
  commandText: string;
  description?: string | null;
  categoryId: string;
  tags?: string[];
}
