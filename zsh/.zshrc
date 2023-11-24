# zmodload zsh/zprof
# Default and Original ZSHRC file
export ZSH="$HOME/.oh-my-zsh"

# Which theme did you want to use
# ZSH_THEME="powerlevel10k/powerlevel10k"
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
    gpg-agent
    docker
    docker-compose
    fancy-ctrl-z
    kubectl
)

source $ZSH/oh-my-zsh.sh
export GOPATH=$(go env GOPATH)/bin
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
)

export CODEFOLDER="$HOME/code"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export EDITOR='nvim'
export GIT_EDITOR='nvim'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

for script in $ZSH_CUSTOM/alex/*.zsh; do source $script; done
source ~/.mano.zsh

# ZSH_TMUX_AUTOSTART=false
# ZSH_TMUX_AUTOCONNECT=false

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git,out,build}"'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/alex/.sdkman"
[[ -s "/Users/alex/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/alex/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
