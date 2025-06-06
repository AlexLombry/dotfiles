GPG_TTY=$(tty)
export GPG_TTY

export APP_ENV="dev"
export DOTFILES=$HOME/dotfiles
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE=C
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export DISPLAY=":0.0"
export EDITOR='nvim'

DISABLE_UNTRACKED_FILES_DIRTY="true"

# zsh builtin to re-run last line. dangerous. do not want. use `!!`.
disable r

# autocd in these paths
cdpath=($(echo $cdpath) $HOME/ManoMano/ /Volumes/ManoManoCode/)
