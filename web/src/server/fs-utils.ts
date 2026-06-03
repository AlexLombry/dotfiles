import fs   from 'node:fs';
import path from 'node:path';
import type { FileStatus, FileEntry, Package } from '../shared/types';
import { STOW_DIR, HOME_DIR } from './config';

const IGNORE_EXACT = new Set<string>([
  '.DS_Store', '.git', '.gitignore', '.gitmodules', '.svn', '_darcs', '.hg',
  'CVS', 'RCS', '.cvsignore', 'COPYING',
]);

export function shouldIgnore(name: string): boolean {
  if (IGNORE_EXACT.has(name)) return true;
  if (name.endsWith('~')) return true;
  if (/^\#.*\#$/.test(name)) return true;
  if (/^README(\..+)?$/.test(name)) return true;
  if (/^LICENSE(\..+)?$/.test(name)) return true;
  return false;
}

export function* walkDir(dir: string): Generator<string> {
  let entries: fs.Dirent[];
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    if (shouldIgnore(e.name)) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) yield* walkDir(full);
    else yield full;
  }
}

// Stow uses directory-level "tree folding" symlinks, e.g.:
//   ~/.config/nvim  →  ../../dotfiles/stow/config/.config/nvim
// Individual files under that dir aren't symlinks themselves but are
// effectively linked. Walk dest's ancestor dirs to detect this case.
export function isEffectivelyLinked(src: string, dest: string): boolean {
  const parts = dest.split(path.sep).filter(Boolean);
  for (let i = parts.length - 1; i > 0; i--) {
    const parentDest = path.sep + parts.slice(0, i).join(path.sep);
    const remaining  = parts.slice(i).join(path.sep);
    let lstat: fs.Stats;
    try { lstat = fs.lstatSync(parentDest); } catch { continue; }
    if (!lstat.isSymbolicLink()) continue;
    try {
      const target   = fs.readlinkSync(parentDest);
      const resolved = path.resolve(path.dirname(parentDest), target);
      if (path.join(resolved, remaining) === src) return true;
    } catch {}
  }
  return false;
}

export function symlinkStatus(src: string, dest: string): FileStatus {
  let lstat: fs.Stats;
  try { lstat = fs.lstatSync(dest); } catch {
    return isEffectivelyLinked(src, dest) ? 'linked' : 'missing';
  }
  if (lstat.isSymbolicLink()) {
    try {
      const target   = fs.readlinkSync(dest);
      const resolved = path.resolve(path.dirname(dest), target);
      return resolved === src ? 'linked' : 'conflict';
    } catch { return 'broken'; }
  }
  return isEffectivelyLinked(src, dest) ? 'linked' : 'conflict';
}

export function scanPackage(name: string): Package {
  const pkgDir = path.join(STOW_DIR, name);
  if (!fs.existsSync(pkgDir)) return { name, files: [], error: 'Package directory not found' };
  const files: FileEntry[] = [];
  for (const src of walkDir(pkgDir)) {
    const rel  = path.relative(pkgDir, src);
    const dest = path.join(HOME_DIR, rel);
    files.push({ rel, src, dest, status: symlinkStatus(src, dest) });
  }
  return { name, files };
}
