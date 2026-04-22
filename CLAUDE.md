# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

All tasks run from `install/Justfile` via `just` (from the repo root or `install/` directory):

```bash
just setup        # Full installation: stow → os → brew → mise → neovim
just stow         # Symlink all packages (zsh git config else work) into $HOME
just unstow       # Remove all symlinks
just brew         # Install from install/BrewFile via Homebrew Bundle
just mise         # Install language runtimes
just os           # Apply macOS system defaults (install/scripts/macos.sh)
just neovim       # Install NeoVim with lua deps (luajit, luarocks, luv)
just update       # Run upd8r to update all package managers
just bench        # Measure zsh startup time (3 runs)
just gpg-pass     # Store GPG backup password in macOS keychain
```

To stow or unstow a single package:

```bash
stow -d stow -t ~ zsh          # Symlink only the zsh package
stow -d stow -t ~ -D config    # Remove symlinks for the config package
```

## Architecture

### Dotfile Management Flow

GNU Stow symlinks packages from `stow/*/` into `$HOME`. The `stow/` directory contains five packages:

- **zsh** — `.zshrc`, `.zprofile`, `.ideavimrc`, Oh My Zsh theme/plugins
- **git** — `.gitconfig`, `.gitignore_global`
- **config** — `.config/nvim/`, `.config/ghostty/`, `.config/rectangle/`, `.config/iterm2/`
- **else** — `.tmux.conf`, `.aerospace.toml`, `.dir_colors`, `.crontab`, `~/Library/` app configs
- **work** — `.work.zsh` (work-specific aliases and env vars)

Each package maps directly to `$HOME` layout. Adding a file at `stow/zsh/.zshrc` means `~/.zshrc` will be symlinked to it after `just stow`.

### Toolchain

| Tool | Role |
|------|------|
| **GNU Stow** | Symlink manager — the core mechanism |
| **Just** | Task runner wrapping all installation steps |
| **Homebrew** | System packages and apps (`install/BrewFile`) |
| **Mise** | Language runtime manager (Node, Python, Ruby, etc.) |
| **Oh My Zsh** | Zsh plugin ecosystem (theme: `awesomepanda`) |

### NeoVim Config

Located at `stow/config/.config/nvim/` — Lua-based, modular:

- `init.lua` — entry point
- `lua/plugins/` — one file per plugin group (lsp, completion, UI, telescope, gitsigns, etc.)
- Uses NvChad as the base configuration (`just chad` clones it)
- LSP managed via Mason (`mason.lua`, `lspconfig.lua`)

### Shell Config

- `.zshrc` sources `~/.mano.zsh` for work config (untracked, not in this repo)
- Runtime managers: NVM (Node legacy), SDKMAN (Java), Mise (everything else)
- GPG/SSH agent configured in `.zprofile`

### Installation Scripts

`install/scripts/` — standalone shell utilities:
- `macos.sh` — macOS system defaults (run via `just os`)
- `journal`, `backup_secure`, `path`, `push` — personal utilities

`install/tools/upd8r/` — shell script updating brew, pip, npm, cargo, etc. (run via `just update`)
