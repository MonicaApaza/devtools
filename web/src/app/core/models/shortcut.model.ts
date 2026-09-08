export interface Shortcut {
  id: string;
  title: string;
  keys: string;
  description: string | null;
  categoryId: string;
  tags: string[];
  isFavorite: boolean;
  createdAt: string;
}

export interface ShortcutRequest {
  title: string;
  keys: string;
  description?: string | null;
  categoryId: string;
  tags?: string[];
}
