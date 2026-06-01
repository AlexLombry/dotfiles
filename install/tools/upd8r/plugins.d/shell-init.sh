#!/usr/bin/env bash
# Regenerate cached shell init files when the source binary is newer than
# the cached output. Cheap (~ms when up to date), bulletproof when not.
set -euo pipefail

ZSH_DIR="$HOME/.zsh"
mkdir -p "$ZSH_DIR" "$ZSH_DIR/completions"

regen_if_stale() {
  local cmd="$1" out="$2"
  shift 2
  local bin
  bin="$(command -v "$cmd" 2>/dev/null || true)"
  [[ -z "$bin" ]] && return 0
  if [[ ! -f "$out" || "$bin" -nt "$out" ]]; then
    echo "🔄 Regenerating $(basename "$out") (newer $cmd binary)"
    "$@" > "$out"
  fi
}

echo "🐚 -- Shell init cache"

regen_if_stale starship "$ZSH_DIR/starship-init.zsh" starship init zsh --print-full-init
regen_if_stale zoxide   "$ZSH_DIR/zoxide-init.zsh"   zoxide init zsh
regen_if_stale uv       "$ZSH_DIR/completions/_uv"   uv generate-shell-completion zsh
regen_if_stale uvx      "$ZSH_DIR/completions/_uvx"  uvx --generate-shell-completion zsh
regen_if_stale gh       "$ZSH_DIR/completions/_gh"   gh completion -s zsh
regen_if_stale glab     "$ZSH_DIR/completions/_glab" glab completion -s zsh
regen_if_stale just     "$ZSH_DIR/completions/_just" just --completions zsh
regen_if_stale k9s      "$ZSH_DIR/completions/_k9s"  k9s completion zsh
regen_if_stale mise     "$ZSH_DIR/completions/_mise" mise completion zsh
regen_if_stale tv       "$ZSH_DIR/completions/_tv"   tv completions zsh

echo ""
