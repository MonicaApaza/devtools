export type CategoryType = 'Shortcut' | 'Command' | 'Both';

/** Icon keys stored on a Category, mapped to Material Symbols ligature names. */
export const ICON_CATALOG: Record<string, string> = {
  code: 'code',
  developer_mode: 'developer_mode',
  diamond: 'diamond',
  git: 'account_tree',
  terminal: 'terminal',
  browser: 'public',
  flutter: 'smartphone',
  pub: 'inventory_2',
  star: 'star',
  bug: 'bug_report',
  cloud: 'cloud',
  settings: 'settings',
  extension: 'extension',
  build: 'build',
  folder: 'folder',
  category: 'category',
};

export const DEFAULT_ICON_KEY = 'category';

export interface Category {
  id: string;
  name: string;
  icon: string;
  type: CategoryType;
  createdAt: string;
}

export interface CategoryRequest {
  name: string;
  icon: string;
  type?: CategoryType;
}
