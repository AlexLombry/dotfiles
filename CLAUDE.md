# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

All tasks run from `install/Justfile` via `just` (from the repo root or `install/` directory):

```bash
just setup        # Full installation: check → stow-fresh → os → brew → mise → completions → init-shell
just check        # Verify prerequisites (brew, just, stow, Xcode CLT)
just stow         # Re-symlink all packages (safe re-run, refuses to clobber)
just stow-fresh   # First-time stow with --adopt (clean machine only)
just stow-check   # Dry-run stow to preview what would be linked
just unstow       # Remove all symlinks
just brew         # Install from install/BrewFile via Homebrew Bundle
just mise         # Install language runtimes
just completions  # Generate uv/uvx shell completions (run once after brew)
just init-shell   # Pre-generate starship/zoxide init for faster shell startup
just os           # Apply macOS system defaults (install/macos.sh)
just backup-agent # Install/reload the backup_secure LaunchAgent
just doctor       # Diagnose stow conflicts, brew drift, stale caches
just update       # Run upd8r to update all package managers
just bench        # Measure zsh startup time (3 runs)
just gpg-pass     # Store GPG backup password in macOS keychain
```

To stow or unstow a single package:

```bash
stow -d stow -t ~ zsh          # Symlink only the zsh package
stow -d stow -t ~ -D config    # Remove symlinks for the config package
```

## Web Interface

A local web UI lives in `web/` for managing symlinks via browser instead of the CLI.

```bash
cd web && npm install   # first time only
just web               # → http://localhost:3131
```

- **`web/server.js`** — Express backend; scans stow packages, runs whitelisted `just` commands, streams output via SSE, handles backup/rollback
- **`web/public/`** — Vanilla JS + Catppuccin Mocha dark UI (no build step)

The scanner resolves both file-level and directory-level stow symlinks (stow tree-folding). Auto-generated conflict backups (`backup/YYYY-MM-DD*/`) are git-ignored; named backups like `Raise2` are tracked.

## Architecture

### Dotfile Management Flow

GNU Stow symlinks packages from `stow/*/` into `$HOME`. The `stow/` directory contains five packages:

- **zsh** — `.zshrc`, `.zprofile`, `.ideavimrc`, Oh My Zsh theme/plugins
- **git** — `.gitconfig`, `.gitignore_global`
- **config** — `.config/nvim/`, `.config/ghostty/`, `.config/mise/`
- **apps** — `.tmux.conf`, `.aerospace.toml`, `.dir_colors`, `.crontab`, `~/Library/` app configs
- **work** — `.work.zsh` (work-specific aliases and env vars)

Each package maps directly to `$HOME` layout. Adding a file at `stow/zsh/.zshrc` means `~/.zshrc` will be symlinked to it after `just stow`.

### Toolchain

| Tool          | Role                                                |
| ------------- | --------------------------------------------------- |
| **GNU Stow**  | Symlink manager — the core mechanism                |
| **Just**      | Task runner wrapping all installation steps         |
| **Homebrew**  | System packages and apps (`install/BrewFile`)       |
| **Mise**      | Language runtime manager (Node, Python, Ruby, etc.) |
| **Oh My Zsh** | Zsh plugin ecosystem                                |
| **Starship**  | Shell prompt (overrides OMZ theme)                  |

### NeoVim Config

Located at `stow/config/.config/nvim/` — Lua-based, modular:

- `init.lua` — entry point
- `lua/plugins/` — one file per plugin group (lsp, completion, UI, telescope, gitsigns, etc.)
- LSP managed via Mason (`mason.lua`, `lspconfig.lua`)
- Custom configuration using `lazy.nvim` (NVChad is no longer used)

### Shell Config

- `.zshrc` sources `~/.work.zsh` — tracked in this repo via the `work` stow package (`stow/work/.work.zsh`)
- Runtime managers: SDKMAN (Java, lazy-loaded), Mise (everything else)
- GPG/SSH agent via YubiKey — configured in `.zshrc`, skipped in dev containers
- uv/uvx completions served from `~/.zsh/completions/` (regenerate with `just completions`)

### Installation Scripts

`install/macos.sh` — macOS system defaults (run via `just os`)

`install/scripts/` — standalone shell utilities: `backup_secure`, `journal`, `path`, `push`

`install/tools/upd8r/` — shell script updating brew, mise, composer, mas, rust (run via `just update`)
