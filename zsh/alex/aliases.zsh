alias vimdiff='nvim -d'
export EDITOR=nvim
alias vim="nvim"
alias oldvim="\vim"
alias cc="clear"

# reload zsh config
alias rld='echo "Reloading Zshrc file" && source ~/.zshrc && tmux source-file $HOME/.tmux.conf && echo "Reload complete"'

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

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias ls="eza --icons"
alias ll="eza -abghl --git --color=automatic --icons"
alias lld="ls -l | grep ^d"
alias gs=gst

# Helpers
alias grep='grep --color=auto'

# Applications
alias ios="open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
alias dot="cd ~/dotfiles"

# Network
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Trim new lines and copy to clipboard
alias trimcopy="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"

# Remove broken symlinks
alias clsym="find -L . -name . -o -type d -prune -o -type l -exec rm {} +"

# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Intuitive map function (from @mathiasbynens)
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# File size
alias fss="stat -f \"%z bytes\""

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

alias gentags="ctags -R --exclude=.git --exclude=node_modules --exclude=build --exclude=out"

# ImageMagick
alias heictojpg="magick convert $1 $1.jpg"
alias heictojpgdir="magick mogrify -monitor -format jpg *.HEIC"

alias meh="echo '¯\\\_(ツ)_/¯' | pbcopy"
alias speed="speedtest --server-id=24215"
alias vim=nvim

alias t='tm'
alias tt='tmux attach -t StarK'

#alias ldk="DOCKER_HOST=unix:///Users/$USER/.colima/docker.sock lazydocker"
alias ta="tmux attach"

# I'll be doing another one for Linux, but this one will give you
# a pop up notification and sound alert (using the built-in sounds for macOS)

# Requires https://github.com/caarlos0/timer to be installed

# Mac setup for pomo
alias work="timer 60m && say -v Samantha 'It is time to take a Break' && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

alias rest="timer 5m && say -v Samantha 'Get back to work' && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

alias sl=l
alias b=bat

alias tun="ssh-tunnel -a create -e all -u alex.lombry"
alias cltun="ssh-tunnel -a close"
alias cleanflared="rm -rf $HOME/.cloudflared/*"

alias zip-encrypt="zip -e -r $1.zip $1"
alias p=python3

# VIM
alias v="/opt/homebrew/bin/nvim"

# Nmap
alias nm="nmap -sC -sV -oN nmap"

alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'
alias splitpdf="pdftoppm -jpeg $1 $2"
alias btc="better-commits"

alias lg=lazygit
alias nte="nvim $HOME/Desktop/myBigNotesRandom.log"
alias mm="cd /Volumes/ManoManoCode/"
