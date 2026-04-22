# Dotfiles Enhancement Proposals

## Bugs / Correctness Issues

### 1. `ZSH_THEME` is dead config
**File:** `stow/zsh/.zshrc:41`

`ZSH_THEME="awesomepanda"` is set but then overridden by `eval "$(starship init zsh)"` at line 186.
Starship replaces the prompt entirely — the theme variable does nothing. Remove it.

### 2. Triple SSH agent management conflict
**File:** `stow/zsh/.zshrc:6-25, 53`

Three mechanisms compete:
- Manual `ssh-agent` spawn (lines 6–8)
- Oh My Zsh `ssh-agent` plugin (line 53)
- GPG-for-SSH block (lines 15–25)

The manual spawn at lines 6–8 is redundant since the GPG block handles `SSH_AUTH_SOCK`.
The OMZ `ssh-agent` plugin may fight with the YubiKey/GPG setup.
Fix: remove lines 6–8 and drop `ssh-agent` from the OMZ plugins list.

### 3. `$HOME/.composer/vendor/bin` duplicated in PATH
**File:** `stow/zsh/.zshrc:80,85`

Added twice. The `typeset -U path` deduplication catches it at runtime, but it's noise.

### 4. Tools used but missing from BrewFile
**File:** `stow/zsh/.zshrc`, `install/BrewFile`

| Tool | Where used | Risk |
|------|-----------|------|
| `starship` | line 186 `eval` | fails silently if absent |
| `bun` | lines 188–193 | PATH setup fails |
| `uv` / `uvx` | lines 195–196 | completions silently skipped |
| `tv` | line 194 | guarded with `command -v`, safe but inconsistent |

### 5. `stow --adopt` is dangerous on re-runs
**File:** `install/Justfile:19`

`stow --adopt` moves existing `$HOME` files *into* the stow directory, overwriting tracked versions.
Safe on a clean machine, destructive if re-run when symlinks exist and have local modifications.
At minimum, document this behaviour. Consider using `--no-folding` without `--adopt` for re-runs.

### 6. `go-task/tap` is an orphaned tap
**File:** `install/BrewFile:1`

The tap is declared but nothing from it is installed (`go-task` was removed; `just` is used instead).
Remove the tap line.

### 7. `kubectl` OMZ plugin but no `kubectl` in BrewFile
**File:** `stow/zsh/.zshrc:55`

The `kubectl` plugin is loaded but `kubectl` is not managed by Homebrew (k9s does not install it).
Either add `brew "kubectl"` to BrewFile or remove the plugin.

### 8. Dead commented-out line in GOPATH block
**File:** `stow/zsh/.zshrc:65`

```zsh
export GOPATH="$HOME/go"
# export GOPATH=$(go env GOPATH)/bin   ← wrong path, dead code
```

Remove the commented line.

---

## Performance — Shell Startup

### 9. `uv`/`uvx` completions spawn subprocesses on every start
**File:** `stow/zsh/.zshrc:195-196`

```zsh
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
```

Same pattern as the old `$(yarn global bin)` issue. Generate once and cache:

```zsh
# Run once (e.g., in just mise or a setup script):
mkdir -p ~/.zsh/completions
uv generate-shell-completion zsh > ~/.zsh/completions/_uv
uvx --generate-shell-completion zsh > ~/.zsh/completions/_uvx

# In .zshrc, replace the two evals with:
fpath=(~/.zsh/completions $fpath)
```

---

## Redundancies

### 10. `reattach-to-user-namespace` is legacy
**File:** `install/BrewFile:40`

Required for macOS/tmux clipboard integration before Sierra. Modern macOS doesn't need it. Remove.

### 11. Justfile `neovim` task duplicates BrewFile
**File:** `install/Justfile:28-31`, `install/BrewFile:31-35`

The `neovim` task runs `brew install luajit luarocks luv neovim --HEAD`, which are already declared
in BrewFile. Running `just setup` installs them twice.

Options:
- Remove them from BrewFile and keep only the `neovim` task (preserves `--HEAD` intent)
- Remove the `neovim` task and let BrewFile handle it (simpler, but loses explicit HEAD flag)

---

## Organization

### 12. Rename `stow/else/` to something meaningful
`else` is vague. Consider `stow/wm/` (AeroSpace, tmux) or `stow/apps/` depending on contents.

---

## Priority Order (Quick Wins First)

| # | Change | Effort |
|---|--------|--------|
| 1 | Remove duplicate `$HOME/.composer/vendor/bin` in PATH | 30s |
| 2 | Remove dead `ZSH_THEME` line | 30s |
| 3 | Remove dead commented GOPATH line | 30s |
| 4 | Remove `go-task/tap` from BrewFile | 30s |
| 5 | Remove `reattach-to-user-namespace` from BrewFile | 30s |
| 6 | Fix SSH agent: remove lines 6–8, drop `ssh-agent` OMZ plugin | 2 min |
| 7 | Add `starship`, `bun`, `uv`/`uvx`, `tv` to BrewFile | 2 min |
| 8 | Add `kubectl` to BrewFile or remove OMZ plugin | 1 min |
| 9 | Cache `uv`/`uvx` completions statically | 5 min |
| 10 | Resolve Justfile `neovim` / BrewFile duplication | 5 min |
| 11 | Document or fix `stow --adopt` behaviour | 10 min |
| 12 | Rename `stow/else/` | 15 min |