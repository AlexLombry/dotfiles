alias vimdiff='nvim -d'
export EDITOR=nvim
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias oldvim="\vim"

# reload zsh config
alias rld='echo "Reloading Zshrc file" && source ~/.zshrc'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

# Filesystem aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias sl="ls"

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias ls="exa --icons"
alias l="exa -abghl --git --color=automatic --icons"
alias la="exa -abghl --git --color=automatic --icons"
alias ll="exa -abghl --git --color=automatic --icons"
alias lld="ls -l | grep ^d"
alias gs="gst"
# Helpers
alias grep='grep --color=auto'

# Applications
alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
alias chrome="/usr/bin/open -a /Applications/Google\ Chrome.app"
alias dot="cd ~/dotfiles"

# Network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Trim new lines and copy to clipboard
alias trimcopy="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Intuitive map function (from @mathiasbynens)
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# File size
alias fss="stat -f \"%z bytes\""

# Empty the Trash on all mounted volumes and the main HDD
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash"

# Show/hide all desktop icons (useful when presenting)
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"

# Show or hide secret file
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Change dock animation
alias killdock="defaults delete com.apple.dock expose-animation-duration; killall Dock"
alias fastdock="defaults write com.apple.dock expose-animation-duration -float 0.01; killall Dock"

alias killmenubar="killall -KILL SystemUIServer"

# Lock the screen (when going AFK)
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Flush Directory Service cache
alias flush="sudo dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Divers
alias loadsshkey="cat ~/.ssh/id_rsa.pub | pbcopy && echo 'Copied to clipboard.'"
alias checkphp="find -L . -name '*.php' -print0 | xargs -0 -n 1 -P 4 php -l"
alias vrc="vim ~/.config/nvim/init.vim"
alias zrc="vim ~/.zshrc"
##alias :q="exit"

# Wi-Fi Commands
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
alias wifi-clean="sudo python ~/dotfiles/tools/cleanwifi_macos.py;"
alias wifi-reboot="networksetup -setairportpower en0 off; networksetup -setairportpower en0 on"
alias wifi-hardware="networksetup -listallhardwareports"
alias wifi-scan="airport scan"
alias wifi-take="networksetup -setairportnetwork en0 $1"
alias wifi-ssid="airport -I|awk '/^ *SSID/ {print $2}'"
alias iface="networksetup -listallhardwareports|grep -A1 Wi-Fi|awk '/Device:/ {print $2}'"

# iOS
alias simulator-run="open -a Simulator.app --args -CurrentDeviceUDID $1"
alias simulator-list="xcrun simctl list"

# Unix
## alias genpass="pwgen -CsB 26 1 | tr -d ' ' | tr -d '\n' | pbcopy"
alias genpass="openssl rand -base64 32 | pbcopy"

alias -s rb=nvim
alias -s log="less -MN"
alias -s html="open"
alias -s php=nvim

alias mute="osascript -e 'set volume output muted true'"
alias sup="osascript -e 'set volume 10'"
alias zrsync="rsync -avzhP"
alias httpbench="wrk -t12 -c400 -d30s"

# Show network connections
# Often useful to prefix with SUDO to see more system level network usage
alias net-connections='lsof -l -i +L -R -V'
alias net-established='lsof -l -i +L -R -V | grep ESTABLISHED'

# Files used, anywhere on the filesystem
alias files-usage='sudo fs_usage -e -f filesystem|grep -v CACHE_HIT|grep -v grep'
# Files being opened
alias files-open='sudo fs_usage -e -f filesystem|grep -v CACHE_HIT|grep -v grep|grep open'
# Files in use in the Users directory
alias files-usage-user='sudo fs_usage -e -f filesystem|grep -v CACHE_HIT|grep -v grep|grep Users'

alias deletefilerecursive="find . -type f -print0 | xargs -0 rm"

# Print each PATH entry on a separate line
alias paths='echo -e ${PATH//:/\\n}'

alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'''
alias dss='du -sck * | sort -n'

alias bubu="brew update && brew upgrade && brew cleanup"
alias brewup='brew update; brew upgrade; brew prune; brew cleanup; brew doctor'
alias bsr="brew services restart $1"

alias ng-web="ngrok http $1 -subdomain=webapp --region=eu"
alias ng-api="ngrok http $1 -subdomain=webapi --region=eu"
alias ng-lo="ngrok http $1 --subdomain=alombry"

alias generate-secure-string="openssl rand -base64 32"

alias opcode="phpdbg -p $1"

alias perm_number="stat -f '%A %N' *"

alias cat=ccat
alias messydesk="defaults write com.apple.finder CreateDesktop"

alias bench="ab -n 500 -c 100 $1"

alias s="sublime"
alias gentags="ctags -R --exclude=.git --exclude=node_modules"

# ImageMagick
alias heictojpg="magick convert $1 $1.jpg"
alias heictojpgdir="magick mogrify -monitor -format jpg *.HEIC"

alias meh="echo '¯\\\_(ツ)_/¯' | pbcopy"
alias phptags="ctags -R --fields=+aimlS"
alias todo="todo -action"
alias runmysql="cd ~/dotfiles/tools; docker-compose up -d"
alias speed="speedtest --server-id=24215"
alias vim=nvim
alias weather='clear && curl wttr.in'

alias t='tmux new-session -s StarK'
alias tt='tmux attach -t StarK'
alias r=ranger
