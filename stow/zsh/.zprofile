# Homebrew environment
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Homebrew Ruby gem bin (Homebrew Ruby itself is in the .zshrc path=() array)
if command -v ruby &>/dev/null; then
    _gem_bin="$(ruby -e 'puts Gem.bindir' 2>/dev/null)"
    [[ -n "$_gem_bin" ]] && export PATH="$_gem_bin:$PATH"
    unset _gem_bin
fi

# XDG / app dirs
export XDG_CONFIG_HOME="$HOME"/.config
export DOTFILES="$HOME/dotfiles"

# Editor + app env
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export APP_ENV="dev"

# Docker / compose timeouts
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
