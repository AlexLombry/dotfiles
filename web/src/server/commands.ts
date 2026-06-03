import type { CommandConfig, CommandEntry, StowMode } from '../shared/types';
import { HOME_DIR } from './config';

export const JUST_CMDS: Readonly<Record<string, CommandConfig>> = {
  check:          { label: 'Check prerequisites',           safe: true,  desc: 'Verify brew, just, stow, and Xcode CLT are installed.' },
  stow:           { label: 'Apply symlinks',                safe: false, desc: 'Symlink all packages to $HOME. Refuses to overwrite existing files.' },
  'stow-fresh':   { label: 'First-time stow (--adopt)',     safe: false, desc: 'Adopt existing $HOME files into the repo. Clean machine only.' },
  'stow-check':   { label: 'Dry-run stow preview',          safe: true,  desc: 'Preview what would be linked without making any changes.' },
  unstow:         { label: 'Remove all symlinks',           safe: false, desc: 'Remove all managed symlinks. Dotfiles repo stays intact.' },
  brew:           { label: 'Install Homebrew bundle',       safe: false, desc: 'Install all packages from install/BrewFile via Homebrew Bundle.' },
  mise:           { label: 'Install language runtimes',     safe: false, desc: 'Install node, python, ruby, and other runtimes via mise.' },
  os:             { label: 'Apply macOS defaults',          safe: false, desc: 'Set macOS system preferences via install/macos.sh.' },
  doctor:         { label: 'Diagnose drift & issues',       safe: true,  desc: 'Check stow conflicts, brew drift, stale caches, compaudit.' },
  'init-shell':   { label: 'Generate shell init files',     safe: false, desc: 'Pre-generate starship/zoxide init scripts for faster startup.' },
  completions:    { label: 'Generate shell completions',    safe: false, desc: 'Regenerate uv/uvx zsh completions.' },
  bench:          { label: 'Benchmark shell startup',       safe: true,  desc: 'Measure zsh startup time across 3 runs.' },
  setup:          { label: 'Full MacBook setup',            safe: false, desc: 'Runs: check → stow-fresh → os → brew → mise → completions → init-shell.' },
  update:         { label: 'Update all packages',           safe: false, desc: 'Run upd8r to update brew, mise, composer, mas, and rust.' },
  'backup-agent': { label: 'Install backup LaunchAgent',   safe: false, desc: 'Install and load the backup_secure LaunchAgent.' },
};

export const STOW_FLAGS: Readonly<Record<StowMode, string[]>> = {
  stow:      ['-v', '-t', HOME_DIR],
  'dry-run': ['-n', '-v', '-t', HOME_DIR],
  unstow:    ['-D', '-v', '-t', HOME_DIR],
  adopt:     ['--adopt', '-v', '-t', HOME_DIR],
};

export function isStowMode(s: string): s is StowMode {
  return s === 'stow' || s === 'dry-run' || s === 'unstow' || s === 'adopt';
}

export function getCommandEntries(): CommandEntry[] {
  return Object.entries(JUST_CMDS).map(([cmd, meta]) => ({ cmd, ...meta }));
}
