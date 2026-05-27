# Dotfiles

![KungFu](install/images/kungfu-2.png)

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Just](https://just.systems/).

## Fresh machine setup

### Step 1 — Bootstrap

Run this in a terminal. It installs Xcode CLT and clones the repo to `~/dotfiles`:

```bash
curl -fsSL https://raw.githubusercontent.com/AlexLombry/dotfiles/refs/heads/main/install/init.sh | zsh
```

### Step 2 — Install everything

Open a **new terminal**, then:

```bash
cd ~/dotfiles && ./install/install.sh
```

This installs Oh My Zsh, Homebrew, Mise, Just, and GNU Stow — then runs `just setup` automatically.

### Step 3 — Restart your terminal

Shell config and custom NeoVim setup are now symlinked. Open a fresh terminal session to pick up all changes.

---

## What `just setup` does

| Step | Task | What it does |
|------|------|-------------|
| 1 | `check` | Verifies prerequisites (Homebrew, Just, Stow, Xcode CLT) |
| 2 | `stow` | Symlinks all packages (`zsh`, `git`, `config`, `apps`, `work`) into `$HOME` |
| 3 | `os` | Applies optimized macOS system defaults (`install/macos.sh`) |
| 4 | `brew` | Installs grouped packages and apps from `install/BrewFile` |
| 5 | `mise` | Installs language runtimes (Python, Node, Ruby) via `mise` |
| 6 | `completions` | Generates `uv`/`uvx` shell completions into `~/.zsh/completions/` |
| 7 | `init-shell` | Generates static initialization for `starship` and `zoxide` for faster startup |

---

## Day-to-day commands

```bash
just              # List all available tasks
just check        # Verify if all prerequisites are installed
just stow         # Re-apply symlinks (e.g. after adding a new dotfile)
just stow-check   # Dry-run check for symlinks
just unstow       # Remove all symlinks
just brew         # Sync Homebrew packages with BrewFile
just mise         # Reinstall/update language runtimes
just init-shell   # Regenerate static shell init files
just update       # Update all package managers (brew, mise, mas…)
just bench        # Measure zsh startup time (3 runs)
just os           # Re-apply macOS system defaults
just completions  # Regenerate uv/uvx completions
just gpg-pass     # Store GPG backup password in macOS Keychain
```

To stow or unstow a single package:

```bash
stow -d ~/dotfiles/stow -t ~ zsh        # Symlink only zsh
stow -d ~/dotfiles/stow -t ~ -D config  # Remove symlinks for config
```

---

## NeoVim

This project uses a custom NeoVim configuration located in `stow/config/.config/nvim`. It is automatically symlinked during the `stow` process. It uses `lazy.nvim` for plugin management.

---

## Work config

`~/.zshrc` sources `~/.work.zsh` for work-specific aliases and environment variables. This file is not tracked in this repo — create it manually on a work machine.
