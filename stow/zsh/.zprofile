# Homebrew environment (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Prefer Homebrew Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
_gem_bin="$(ruby -e 'puts Gem.bindir' 2>/dev/null)"
[[ -n "$_gem_bin" ]] && export PATH="$_gem_bin:$PATH"
unset _gem_bin
export XDG_CONFIG_HOME="$HOME"/.config
