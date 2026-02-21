if [[ "$OSTYPE" == "darwin"* ]]; then
	# needed for brew
	eval "$(/opt/homebrew/bin/brew shellenv)"
  export XDG_RUNTIME_DIR="$HOME"/Library/Caches/TemporaryItems
fi

export XDG_CONFIG_HOME="$HOME"/.config
