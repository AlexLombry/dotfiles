# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zmodload zsh/zprof
# Default and Original ZSHRC file
export ZSH="$HOME/.oh-my-zsh"
export GPG_TTY=$(tty)

HISTSIZE=
SAVEHIST=

# Which theme did you want to use
ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="awesomepanda"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$ZSH/custom"

plugins=(
    git 
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    extract
    ssh-agent
    gpg-agent
    docker-compose
    fancy-ctrl-z
    kubectl
#    git-commit
 mise)

source $ZSH/oh-my-zsh.sh
source $HOME/dotfiles/zsh/alex/ext.zsh

export GOPATH="$HOME/go"
# export GOPATH=$(go env GOPATH)/bin
# User configuration

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
)

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

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/alex/.sdkman"
[[ -s "/Users/alex/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/alex/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Herd injected PHP binary.
export PHP_INI_SCAN_DIR="/Users/alex/Library/Application Support/Herd/config/php/":$PHP_INI_SCAN_DIR


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/alex/Library/Application Support/Herd/config/php/82/"

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# export NVM_DIR="$HOME/.nvm"
#   [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
#   [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Herd injected PHP binary.
export PATH="/Users/alex/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/alex/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/alex/Library/Application Support/Herd/config/php/74/"
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export DOCKER_HOST=unix://${HOME}/.colima/docker.sock
