# Interactive-shell-only zsh tweaks.
# (Env vars previously here were moved to .zprofile so they propagate to
# non-interactive child processes — scripts, cron, launchd-spawned GUIs.)

if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && -z "$DEVCONTAINER_TYPE" ]]; then
    GPG_TTY=$(tty)
    export GPG_TTY
fi

DISABLE_UNTRACKED_FILES_DIRTY="true"

# zsh builtin to re-run last line. dangerous. do not want. use `!!`.
disable r
