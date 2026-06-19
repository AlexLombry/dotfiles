_root := justfile_directory()
_stow := _root / "stow"
_install := _root / "install"
_web := _root / "web"

# List available recipes
default:
    @just --list

# ── Setup ────────────────────────────────────────────────────────────────────

# Complete setup for a new MacBook (uses --adopt for first-time stow)
setup: check stow-fresh os brew mise completions init-shell
    @echo "🚀 MacBook Setup Complete! Please restart your terminal."

# Verify prerequisites (brew, just, stow, Xcode CLT)
check:
    @command -v brew   >/dev/null 2>&1 || (echo "Homebrew is not installed. Please install it first." && exit 1)
    @command -v just   >/dev/null 2>&1 || (echo "Just is not installed. Please install it first." && exit 1)
    @command -v stow   >/dev/null 2>&1 || (echo "Stow is not installed. Please install it first." && exit 1)
    @xcode-select -p   >/dev/null 2>&1 || (echo "Xcode Command Line Tools are not installed." && exit 1)
    @echo "All prerequisites are met!"

# ── Stow ─────────────────────────────────────────────────────────────────────

# Apply symlinks with GNU Stow (safe for re-runs — refuses to clobber)
stow:
    @cd "{{_stow}}" && stow -t "$HOME" zsh git config apps work
    @echo "Symlinks applied!"

# First-time stow with --adopt (clean machine only — overwrites tracked files with $HOME copies)
stow-fresh:
    @cd "{{_stow}}" && stow --adopt -t "$HOME" zsh git config apps work
    @echo "Symlinks applied (with --adopt). Run 'git diff' to inspect what was adopted."

# Dry-run: preview what would be linked without making changes
stow-check:
    @cd "{{_stow}}" && stow -n -v -t "$HOME" zsh git config apps work

# Remove all managed symlinks
unstow:
    @cd "{{_stow}}" && stow -D -t "$HOME" zsh git config apps work
    @echo "Symlinks removed!"

# ── Install ───────────────────────────────────────────────────────────────────

# Install Homebrew bundle from BrewFile
brew:
    HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="{{_install}}/BrewFile"

# Install language runtimes with Mise (Node, Python, Ruby, …)
mise:
    mise install
    mise use -g

# Apply macOS system defaults
os:
    @bash "{{_install}}/macos.sh"
    @echo "Setup OS done!"

# ── Shell ─────────────────────────────────────────────────────────────────────

# Pre-generate starship/zoxide init scripts for faster shell startup
init-shell:
    @mkdir -p ~/.zsh
    starship init zsh --print-full-init > ~/.zsh/starship-init.zsh
    zoxide init zsh > ~/.zsh/zoxide-init.zsh
    @echo "Shell init files generated!"

# Generate uv/uvx shell completions (run once after brew)
completions:
    @mkdir -p ~/.zsh/completions
    @uv generate-shell-completion zsh > ~/.zsh/completions/_uv
    @uvx --generate-shell-completion zsh > ~/.zsh/completions/_uvx
    @echo "Completions generated!"

# Measure zsh startup time (3 runs)
bench:
    @for i in 1 2 3; do /usr/bin/time zsh -i -c exit; done

# ── Maintenance ───────────────────────────────────────────────────────────────

# Run upd8r to update brew, mise, composer, mas, and rust
update:
    @bash "{{_install}}/tools/upd8r/upd8r.sh"

# Diagnose drift: stow conflicts, brew drift, mise outdated, stale caches, compaudit
doctor:
    @echo "🩺  Dotfiles doctor"
    @echo "───────────────────"
    @echo
    @echo "▶ Stow (dry-run)"
    @cd "{{_stow}}" && stow -n -v -t "$HOME" zsh git config apps work 2>&1 | sed 's/^/  /' || true
    @echo
    @echo "▶ Homebrew bundle drift"
    @HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="{{_install}}/BrewFile" --verbose 2>&1 | sed 's/^/  /' || true
    @echo
    @echo "▶ Mise outdated"
    @mise outdated 2>&1 | sed 's/^/  /' || true
    @echo
    @echo "▶ Cached shell init freshness"
    @if [ -f ~/.zsh/starship-init.zsh ] && [ "$$(command -v starship)" -nt ~/.zsh/starship-init.zsh ]; then \
        echo "  ⚠️  starship binary newer than cached init — run 'just init-shell'"; \
    else \
        echo "  ✓ starship-init.zsh up to date"; \
    fi
    @if [ -f ~/.zsh/zoxide-init.zsh ] && [ "$$(command -v zoxide)" -nt ~/.zsh/zoxide-init.zsh ]; then \
        echo "  ⚠️  zoxide binary newer than cached init — run 'just init-shell'"; \
    else \
        echo "  ✓ zoxide-init.zsh up to date"; \
    fi
    @echo
    @echo "▶ Completion freshness"
    @if [ -f ~/.zsh/completions/_uv ] && [ "$$(command -v uv)" -nt ~/.zsh/completions/_uv ]; then \
        echo "  ⚠️  uv binary newer than cached completion — run 'just completions'"; \
    else \
        echo "  ✓ uv completion up to date"; \
    fi
    @echo
    @echo "▶ Compinit security audit"
    @zsh -ic 'autoload -Uz compaudit; out="$(compaudit)"; if [[ -z "$out" ]]; then print "  ✓ no insecure completion directories"; else print "  ⚠️  insecure dirs in fpath:"; print -- "$out" | sed "s/^/    /"; fi' 2>/dev/null
    @echo
    @echo "Doctor done."

# ── Backup ────────────────────────────────────────────────────────────────────

# Store GPG backup password in macOS Keychain
gpg-pass:
    security add-generic-password -a "$$USER" -s backup-gpg -w -U

# Install and reload the backup_secure LaunchAgent
backup-agent:
    @mkdir -p "$HOME/Library/LaunchAgents"
    @sed "s|__HOME__|$$HOME|g" "{{_install}}/templates/com.alexlombry.backup_secure.plist.tmpl" \
        > "$HOME/Library/LaunchAgents/com.alexlombry.backup_secure.plist"
    @launchctl bootout "gui/$$(id -u)/com.alexlombry.backup_secure" 2>/dev/null || true
    @launchctl bootstrap "gui/$$(id -u)" "$HOME/Library/LaunchAgents/com.alexlombry.backup_secure.plist"
    @echo "LaunchAgent installed and loaded."

# ── Web UI ────────────────────────────────────────────────────────────────────

# Start the dotfiles web UI → http://localhost:3131
web:
    @cd "{{_web}}" && npm run build && npm start

# Install Secure Zip tooling
secure:
	@echo "🔏Install as a link the Secure files and folders tooling."
	@sudo ln -sf "$HOME/dotfiles/install/tools/secure.sh" "/usr/local/bin/secure"
