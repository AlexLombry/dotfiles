# zmodload zsh/zprof
# Default and Original ZSHRC file
# Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export ZSH="$HOME/.oh-my-zsh"

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" >/dev/null
fi

# ~~~~~~~~~~~~~~~ SSH ~~~~~~~~~~~~~~~~~~~~~~~~

# Using GPG + YubiKey for ssh.
# Don't execute when in dev container

if [[ -z "$REMOTE_CONTAINERS" && -z "$CODESPACES" && -z "$DEVCONTAINER_TYPE" ]]; then
  export GPG_TTY="$(tty)"
  unset SSH_AGENT_PID

  if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi

  gpgconf --launch gpg-agent
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1
fi

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_SPACE  # Don't save when prefixed with space
setopt HIST_IGNORE_DUPS   # Don't save duplicate lines
setopt SHARE_HISTORY      # Share history between sessions

# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

# Which theme did you want to use
ZSH_THEME="awesomepanda"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$ZSH/custom"

plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    extract
    ssh-agent
    docker-compose
    fancy-ctrl-z
    kubectl
#    git-commit
 mise)

source $ZSH/oh-my-zsh.sh
source $HOME/.oh-my-zsh/custom/alex/ext.zsh

export GOPATH="$HOME/go"
# export GOPATH=$(go env GOPATH)/bin
# User configuration

# ~~~~~~~~~~~~~~~ Path configuration ~~~~~~~~~~~~~~~~~~~~~~~~

setopt extended_glob null_glob

path=(
    $path
    ~/.local/bin
    /usr/local/opt/mysql-client/bin
    /usr/local/opt/python/libexec/bin
    /opt/homebrew/opt/ruby/bin
    $GOPATH/bin/
    ${KREW_ROOT:-$HOME/.krew}/bin
    $HOME/.composer/vendor/bin
    $HOME/.symfony/bin
    /usr/local/sbin
    /usr/local/opt/awscli@1/bin
    $HOME/Library/Python/2.7/bin
    /opt/homebrew/opt/openjdk@17/bin
    $(yarn global bin)
    $HOME/.composer/vendor/bin
    $HOME/dotfiles/install/scripts
)

# Remove duplicate entries and non-existent directories
typeset -U path
path=($^path(N-/))

export PATH

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

export CODEFOLDER="$HOME/code"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export EDITOR='nvim'
export GIT_EDITOR='nvim'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

for script in $ZSH_CUSTOM/alex/*.zsh; do source $script; done
source ~/.mano.zsh

# ZSH_TMUX_AUTOSTART=false
# ZSH_TMUX_AUTOCONNECT=false
export LIBRARY_PATH="/opt/homebrew/lib"
export CPATH="/opt/homebrew/include"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git,out,build}"'

eval "$(zoxide init --cmd cd zsh)"

export SDKMAN_DIR="/Users/alex/.sdkman"
[[ -s "/Users/alex/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/alex/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Open Buffer for command
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x' edit-command-line

# -------------------------------------------
# 2. Undo in ZSH
# -------------------------------------------
# Press Ctrl+_ (Ctrl+Underscore) to undo
# This is built-in, no configuration needed!
# Redo widget exists but has no default binding:
# bindkey '^Y' redo  # Example binding if you want it

# -------------------------------------------
# 3. Magic Space - Expand History
# -------------------------------------------
# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

alias -s json=jless
alias -s md=bat
alias -s go='$EDITOR'
alias -s rs='$EDITOR'
alias -s txt=bat
alias -s log=bat
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s html=open  # macOS: open in default browser

# Pipe to jq
alias -g J='| jq'

# Copy output to clipboard (macOS)
alias -g C='| pbcopy'
# -------------------------------------------
# zmv - Advanced Batch Rename/Move
# -------------------------------------------
# Enable zmv
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)

# Helpful aliases for zmv
alias zcp='zmv -C'  # Copy with patterns
alias zln='zmv -L'  # Link with patterns

# -------------------------------------------
# Named Directories - Bookmark Folders
# -------------------------------------------
# Access with ~name syntax, e.g., cd ~yt or ls ~yt
hash -d dot=~/.dotfiles
hash -d dl=~/Downloads

bindkey -s '^Gc' 'git commit -m ""\C-b'

export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export DOCKER_HOST=unix://${HOME}/.colima/docker.sock

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"
