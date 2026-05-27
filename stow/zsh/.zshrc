# -----------------------------------------------------------------------------
# Paths / core env
# -----------------------------------------------------------------------------
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

export GOPATH="$HOME/go"
export CODEFOLDER="$HOME/code"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

if [[ -n "$HOMEBREW_PREFIX" ]]; then
    export LIBRARY_PATH="$HOMEBREW_PREFIX/lib"
    export CPATH="$HOMEBREW_PREFIX/include"
fi
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
export HISTIGNORE="journal*"
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
setopt extended_glob
setopt null_glob

# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------
path=(
    ~/.local/bin
    /opt/homebrew/opt/ruby/bin
    "$GOPATH/bin"
    "${KREW_ROOT:-$HOME/.krew}/bin"
    "$HOME/.composer/vendor/bin"
    "$HOME/.symfony/bin"
    /usr/local/sbin
    "$HOME/.yarn/bin"
    "$HOME/dotfiles/install/scripts"
    $path
    "$HOME/.bun/bin"
)
typeset -U path
path=($^path(N-/))
export PATH

# -----------------------------------------------------------------------------
# Completions
# Keep this early, but cache aggressively.
# -----------------------------------------------------------------------------
fpath=(
    "$HOME/.zsh/completions"
    $fpath
)

autoload -Uz compinit
# Use cached dump when possible; fewer checks, faster startup.
compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------
# Explicitly disable OMZ theme to avoid conflicts with Starship
ZSH_THEME=""

plugins=(
    git
    extract
    docker-compose
    fancy-ctrl-z
    kubectl
    fzf
    git-commit
    mise
)

source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# SSH / GPG
# -----------------------------------------------------------------------------
if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && -z "$DEVCONTAINER_TYPE" ]]; then
    unset SSH_AGENT_PID

    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi
fi

# -----------------------------------------------------------------------------
# Custom scripts
# Source after compinit so compdef exists.
# -----------------------------------------------------------------------------
for script in "$ZSH_CUSTOM"/alex/*.zsh(N); do
    source "$script"
done

[ -f "$HOME/.mano.zsh" ] && source "$HOME/.mano.zsh"
[ -f "$HOME/.work.zsh" ] && source "$HOME/.work.zsh"

# -----------------------------------------------------------------------------
# Optional tooling: lazy-load instead of startup-load
# -----------------------------------------------------------------------------
sdk() {
    unfunction sdk
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
}

# -----------------------------------------------------------------------------
# UI / keybindings
# -----------------------------------------------------------------------------
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh"

autoload -Uz edit-command-line zmv
zle -N edit-command-line
bindkey '^x' edit-command-line
bindkey ' ' magic-space
bindkey -s '^Gc' 'git commit -m ""\C-b'

# -----------------------------------------------------------------------------
# Aliases / helpers
# -----------------------------------------------------------------------------
alias -s json=jless
alias -s md=bat
alias -s go='$EDITOR'
alias -s rs='$EDITOR'
alias -s txt=bat
alias -s log=bat
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s html=open

alias -g J='| jq'
alias -g C='| pbcopy'

alias zcp='zmv -C'
alias zln='zmv -L'

hash -d dot=~/dotfiles
hash -d dl=~/Downloads

# -----------------------------------------------------------------------------
# Tools that are fine to init after core shell is ready
# -----------------------------------------------------------------------------
if command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git,out,build}"'
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Syntax highlighting & Autosuggestions (from Homebrew)
for plugin in \
    /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
do
    [ -f "$plugin" ] && source "$plugin"
done

if command -v starship &>/dev/null; then
    if [ -f ~/.zsh/starship-init.zsh ]; then
        source ~/.zsh/starship-init.zsh
    else
        eval "$(starship init zsh)"
    fi
fi

command -v tv &>/dev/null && eval "$(tv init zsh)"

# bun completions ($HOME/.bun/bin is in the path=() array above)
export BUN_INSTALL="$HOME/.bun"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# zoxide must be initialized last
if command -v zoxide &>/dev/null; then
    if [ -f ~/.zsh/zoxide-init.zsh ]; then
        source ~/.zsh/zoxide-init.zsh
    else
        eval "$(zoxide init zsh)"
    fi
fi

