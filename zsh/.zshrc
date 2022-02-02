# Default and Original ZSHRC file
export ZSH="$HOME/.oh-my-zsh"

# Which theme did you want to use
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="awesomepanda"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="$ZSH/custom"

plugins=(git zsh-syntax-highlighting zsh-autosuggestions zsh-completions extract ssh-agent gpg-agent docker docker-compose fancy-ctrl-z)

# Needed to reload plugins
autoload -U compinit && compinit
autoload -U promptinit; promptinit

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="/usr/local/opt/mysql-client/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export CODEFOLDER="$HOME/code"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export EDITOR='nvim'
export GIT_EDITOR='nvim'

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

for script in $ZSH_CUSTOM/alex/*.zsh; do source $script; done
source ~/.mano.zsh

#typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
#typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/alex/.sdkman"
[[ -s "/Users/alex/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/alex/.sdkman/bin/sdkman-init.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

