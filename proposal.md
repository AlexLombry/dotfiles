# Dotfiles Enhancement Proposals

## Bugs / Correctness Issues

### 1. Wrong dotfiles bookmark path
**File:** `stow/zsh/.zshrc:175`

```zsh
# Current (wrong)
hash -d dot=~/.dotfiles

# Fix: repo is at ~/dotfiles
hash -d dot=~/dotfiles
```

### 2. `~/.mano.zsh` is untracked
**File:** `stow/zsh/.zshrc:106`

This work config is sourced but lives outside the stow system. Add a fallback guard at minimum:

```zsh
[ -f ~/.mano.zsh ] && source ~/.mano.zsh
```

Long-term: create a `stow/work/` package with a `.work.zsh` file that gets conditionally symlinked.

### 3. `jless` missing from BrewFile
Used in a suffix alias (`alias -s json=jless`) but not declared in `install/BrewFile`.

```ruby
brew "jless"
```

### 4. `tv init zsh` references unknown tool
**File:** `stow/zsh/.zshrc:195`

`tv` is not in BrewFile. Either add it as a dependency or remove the stale line.

---

## Performance — Shell Startup

### 5. `$(yarn global bin)` in PATH is slow
**File:** `stow/zsh/.zshrc:86`

Executes a subprocess on every shell start. Replace with a static path:

```zsh
# Remove this:
$(yarn global bin)

# Add this:
$HOME/.yarn/bin
```

### 6. Replace NVM with mise for Node.js
NVM adds ~200-500ms to every shell startup. `mise` is already installed and can manage Node:

```zsh
mise use -g node@lts
```

Then remove `nvm` from BrewFile and the NVM init block from `.zshrc` (lines 183-185).

### 7. Lazy-load SDKMAN
SDKMAN loads synchronously and is rarely needed on every shell. Lazy-load it:

```zsh
sdk() {
  unfunction sdk
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk "$@"
}
```

### 8. Enable startup profiling
`zmodload zsh/zprof` is already prepared at line 1 of `.zshrc` but commented out.
Uncomment it and add `zprof` at the very end to measure startup time breakdown.

---

## Redundancies in BrewFile

| Tool to remove | Superseded by |
|----------------|---------------|
| `ack` | `ripgrep` (already installed) |
| `ccat` | `bat` (already installed) |
| `go-task` | `just` (the actual task runner used) |
| `nvm` | `mise` (already manages runtimes) |

---

## Legacy PATH entries

**File:** `stow/zsh/.zshrc`

These paths are dead weight and slow down PATH resolution:

```zsh
/usr/local/opt/awscli@1/bin     # awscli v1 is EOL, upgrade to v2
$HOME/Library/Python/2.7/bin    # Python 2.7 is EOL
```

---

## Justfile Improvements

Add the following tasks to `install/Justfile`:

```just
# Unlink all stow symlinks
unstow:
    @cd $$HOME/dotfiles/stow && stow -D -t "$$HOME" zsh git config else
    @echo "Symlinks removed!"

# Run upd8r to update all package managers
update:
    @$$HOME/dotfiles/install/tools/upd8r/upd8r.sh

# Benchmark shell startup time
bench:
    @for i in 1 2 3; do /usr/bin/time zsh -i -c exit; done
```

---

## Organization

### Rename `stow/else/` to something meaningful
`else` is vague. Consider `stow/wm/` (window manager configs: tmux, aerospace, sketchybar)
or `stow/apps/` depending on what ends up there.

### Consolidate work-specific config
Work concerns are currently split between:
- `stow/zsh/.oh-my-zsh/custom/alex/ext.zsh` (cdpath `$HOME/ManoMano/`)
- `~/.mano.zsh` (untracked)

Create a `stow/work/` stow package with `.work.zsh` for all ManoMano-specific config,
sourced conditionally from `.zshrc`.

### Add a README
A minimal `README.md` at the repo root describing the bootstrap flow would help on a fresh machine:

```
curl https://raw.githubusercontent.com/AlexLombry/dotfiles/main/install/init.sh | zsh
# → install.sh → just setup
```

---

## Priority Order (Quick Wins First)

| # | Change | Effort |
|---|--------|--------|
| 1 | Fix `hash -d dot` path | 30s |
| 2 | Add `[ -f ]` guard on `.mano.zsh` | 1 min |
| 3 | Add `jless` to BrewFile | 30s |
| 4 | Remove `ack`, `ccat`, `go-task`, `nvm` from BrewFile | 2 min |
| 5 | Replace `$(yarn global bin)` with static path | 1 min |
| 6 | Remove legacy PATH entries (Python 2.7, awscli@1) | 1 min |
| 7 | Add `unstow`, `update`, `bench` to Justfile | 5 min |
| 8 | Lazy-load SDKMAN | 5 min |
| 9 | Migrate Node from NVM to mise | 15 min |
| 10 | Create `stow/work/` package | 30 min |
