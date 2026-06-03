import path from 'node:path';
import os   from 'node:os';

// dist/server/ is 3 levels deep inside web/, so resolve 3 dirs up to reach dotfiles/
export const DOTFILES_DIR = path.resolve(__dirname, '..', '..', '..');
export const STOW_DIR     = path.join(DOTFILES_DIR, 'stow');
export const INSTALL_DIR  = path.join(DOTFILES_DIR, 'install');
export const HOME_DIR     = os.homedir();
export const BACKUP_BASE  = path.join(DOTFILES_DIR, 'backup');
export const PORT         = Number(process.env['PORT']) || 3131;

export const PACKAGES = ['zsh', 'git', 'config', 'apps', 'work'] as const;
export type KnownPackage = typeof PACKAGES[number];
