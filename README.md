# Dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and [Just](https://just.systems/).

## Fresh machine setup

### Step 1 — Bootstrap

Run this in a terminal. It installs Xcode CLT and clones the repo to `~/dotfiles`:

```bash
curl -fsSL https://raw.githubusercontent.com/AlexLombry/dotfiles/main/install/init.sh | zsh
```

### Step 2 — Install everything

Open a **new terminal**, then:

```bash
cd ~/dotfiles && ./install/install.sh
```

This installs Oh My Zsh, Homebrew, Mise, Just, and GNU Stow — then runs `just setup` automatically.

### Step 3 — NeoVim

After setup completes, install NvChad (safe to re-run):

```bash
just chad
```

### Step 4 — Restart your terminal

Shell config is now symlinked. Open a fresh terminal session to pick up all changes.

---

## What `just setup` does

| Step | Task | What it does |
|------|------|-------------|
| 1 | `stow` | Symlinks all packages (`zsh`, `git`, `config`, `apps`, `work`) into `$HOME` |
| 2 | `os` | Applies macOS system defaults (`install/scripts/macos.sh`) |
| 3 | `brew` | Installs all packages and apps from `install/BrewFile` |
| 4 | `mise` | Installs language runtimes (Python 3.12, Node 22, Ruby 3.3) |
| 5 | `completions` | Generates `uv`/`uvx` shell completions into `~/.zsh/completions/` |

---

## Day-to-day commands

```bash
just              # List all available tasks
just stow         # Re-apply symlinks (e.g. after adding a new dotfile)
just unstow       # Remove all symlinks
just brew         # Sync Homebrew packages with BrewFile
just mise         # Reinstall/update language runtimes
just update       # Update all package managers (brew, pip, npm, cargo…)
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

## Work config

`~/.zshrc` sources `~/.work.zsh` and `~/.mano.zsh` for work-specific aliases and environment variables. These are not tracked in this repo — create them manually on a work machine.
