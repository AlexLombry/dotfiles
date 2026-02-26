####################
# functions
####################
# Colors
setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        ESC_SEQ="\x1b["
        RESET=$ESC_SEQ"39;49;00m"
        RED=$ESC_SEQ"31;01m"
        GREEN=$ESC_SEQ"32;01m"
        YELLOW=$ESC_SEQ"33;01m"
        BLUE=$ESC_SEQ"34;01m"
        MAGENTA=$ESC_SEQ"35;01m"
        CYAN=$ESC_SEQ"36;01m"
    else
        ESC_SEQ=""
        RESET=$ESC_SEQ""
        RED=$ESC_SEQ""
        GREEN=$ESC_SEQ""
        YELLOW=$ESC_SEQ""
        BLUE=$ESC_SEQ""
        MAGENTA=$ESC_SEQ""
        CYAN=$ESC_SEQ""
    fi
}

setup_color

ok() {
    echo -e "\n$GREEN [ok] $RESET "$1
}

bot() {
    echo -e "\n$GREEN\[._.]/$RESET - "$1
}

running() {
    echo -en "\n$YELLOW ⇒ $RESET"$1": "
}

action() {
    echo -e "\n$YELLOW [action]: $RESET\n ⇒ $1..."
}

warn() {
    echo -e "\n$YELLOW [warning] $RESET "$1
}

error() {
    echo -e "$RED [error] $RESET "$1
}

# print available colors and their numbers
colours() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m colour${i}"
        if (( $i % 5 == 0 )); then
            printf "\n"
        else
            printf "\t"
        fi
    done
}

# Create a new directory and enter it
mkcd() {
    mkdir -p "$@" && cd "$@"
}

hist() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# find shorthand
f() {
    find . -name "$1"
}

# navigation
cx() {
    cd "$@" && l;
}

fcd() {
    cd "$(find . -type d -not -path '*/.*' | fzf)" && l;
}

f() {
    echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy
}

fv() {
    nvim "$(find . -type f -not -path '*/.*' | fzf)"
}

# get the gps coordinates from a picture
lats-from-picture() {
    lat=$(mdls $1 | grep Latitude | awk '{print $3}')
    long=$(mdls $1 | grep Longitude | awk '{print $3}')
    echo Photo was taken at $lat / $long

    echo https://www.google.fr/maps/search/$lat,$long

    if [ -n "$lat" ]; then
        open https://www.google.fr/maps/search/$lat,$long
    fi
}

# get gzipped size
gz() {
    echo "orig size    (bytes): "
    cat "$1" | wc -c
    echo "gzipped size (bytes): "
    gzip -c "$1" | wc -c
}

# All the dig info
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# Escape UTF-8 characters into their 3-byte format
escape() {
    printf "\\\x%s" $(printf "$@" | xxd -p -c1 -u)
    echo # newline
}

# Decode \x{ABCD}-style Unicode escape sequences
unidecode() {
    perl -e "binmode(STDOUT, ':utf8'); print \"$@\""
    echo # newline
}

# Extract archives - use: extract <file>
# Credits to http://dotfiles.org/~pseup/.bashrc
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) rar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# humain more readable size for file and folder
fs() {
    if du -b /dev/null > /dev/null 2>&1; then
        local arg=-sbh;
    else
        local arg=-sh;
    fi
    if [[ -n "$@" ]]; then
        du $arg -- "$@";
    else
        du $arg .[^.]* *;
    fi;
}

# set the background color to light
light() {
    export BACKGROUND="light" && reload!
}

dark() {
    export BACKGROUND="dark" && reload!
}

# Better tree functionality
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

#########################################
# Use Preview to open a man page
manp() {
    man -t $1 | open -f -a /Applications/Preview.app
}

# kill all instances of a process by name
skill() {
    sudo kill -9 `ps ax | grep $1 | grep -v grep | awk '{print $1}'`
}

fixperms(){
    find . \( -name "*.sh" -or -type d \) -exec chmod 755 {} \; && find . -type f ! -name "*.sh" -exec chmod 644 {} \;
}

# Xcode via @orta
openx(){
  if test -n "$(find . -maxdepth 1 -name '*.xcworkspace' -print -quit)"
  then
    echo "Opening workspace"
    open *.xcworkspace
    return
  else
    if test -n "$(find . -maxdepth 1 -name '*.xcodeproj' -print -quit)"
    then
      echo "Opening project"
      open *.xcodeproj
      return
    else
      echo "Nothing found"
    fi
  fi
}

# Go to the root of the current git project, or just go one folder up
up() {
  export git_dir="$(git rev-parse --show-toplevel 2> /dev/null)"
  if [ -z $git_dir ]
  then
    cd ..
  else
    cd $git_dir
  fi
}

compresspdf() {
    gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
}

# Send my public SSH key to another machine
copysshkey () {
    cat ~/.ssh/id_rsa.pub | ssh $1 'cat >> .ssh/authorized_keys'
}

cdf() {
    # cd into whatever is the forefront Finder window.
    local path=$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')
    echo "$path"
    cd "$path"
}

duration() {
    ffmpeg -i $1 2>&1 | grep Duration | cut -d ' ' -f 4 | sed s/,//
}

thumbnail() {
    ffmpeg -i $1 -vframes 1 -an -s 400x225 -ss $2 $3
}

encode() {
    ffmpeg -y -i $1 -c:v libx264 -preset slow -profile:v high -crf 18 -coder 1 -pix_fmt yuv420p -movflags +faststart -g 30 -bf 2 -c:a aac -b:a 384k -profile:a aac_low $2
}

freeport() {
  PORT=$1
  PID=`lsof -ti tcp:$PORT`
  if [ -z "$PID"]; then
    echo "No process running on port $PORT"
  else
    kill -KILL $PID
  fi
}

# Create a data URL from a file
dataurl() {
    local mimeType=$(file -b --mime-type "$1");
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8";
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}

video-duration() {
    find . -type f -exec mediainfo --Inform="General;%Duration%" "{}" \; 2>/dev/null | awk '{s+=$1/1000} END {h=s/3600; s=s%3600; printf "%.2d:%.2d\n", int(h), int(s/60)}'
}

sysupdate() {
    sudo softwareupdate --all --install --force
    brew update
    brew upgrade
    brew cleanup
    npm install npm -g
    npm update -g
    sudo gem update --system
    sudo gem update
    sudo gem cleanup
    composer self-update
}

to-mp3() {
    for f in *.ac3; do
        ffmpeg -i "$f" "$f.mp3"
        # /usr/bin/afconvert -d '.mp3' -f MPG3 "$f" -o "$f.mp3"
        echo "$f converted"
    done
}

gpgenc() {
    CUR_FILE=$1
    gpg --output $CUR_FILE.gpg --encrypt --recipient $2 $CUR_FILE
}

gpgencwithrecipient() {
    CUR_FILE=$1
    gpg --output $CUR_FILE.gpg --encrypt --recipient $2 $CUR_FILE
}

gpgdec() {
    CUR_FILE=$1
    STRIP=$(echo $1 | sed 's/.gpg//')
    gpg --output $STRIP --decrypt $CUR_FILE
}

sslenc() {
    CUR_FILE=$1
    openssl enc -aes-256-cbc -salt -in $CUR_FILE -out $CUR_FILE.enc
}

ssldec() {
    CUR_FILE=$1
    STRIP=$(echo $1 | sed 's/.enc//')
    openssl enc -d -aes-256-cbc -in $CUR_FILE -out $STRIP
}

ncx() {
    nc -l -n -vv -p $1 -k
}

ipinfo() {
    curl http://ipinfo.io/$1
}

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

arc() {
    tar -zcvf "$1.tar.gz" "$1"
}

unarc() {
    tar -xvf "$1"
}

# Open a github/gitlab repo in the browser
hb() {
  if [ ! -d .git ] && ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ERROR: This isnt a git directory" && return false
  fi
  git_url=$(git config --get remote.origin.url)
  if [[ $git_url == https://gitlab* ]]; then
    url=${git_url%.git}
  elif [[ $git_url == https://github* ]]; then
    url=${git_url%.git}
  elif [[ $git_url == git@gitlab* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  elif [[ $git_url == git@github* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  elif [[ $git_url == git://github* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  else
    echo "ERROR: Remote origin is invalid" && return false
  fi
  open $url
}

whoseport() {
  lsof -i ":$1" | grep LISTEN
}

killport() {
  lsof -t -i ":$1" | xargs kill -9
}

pw () {
    pwgen -sync "${1:-48}" -1 | if command -v pbcopy > /dev/null 2>&1; then pbcopy; else xclip; fi
}

### Functions for setting and getting environment variables from the OSX keychain ###
### Adapted from https://www.netmeister.org/blog/keychain-passwords.html ###

# Use: keychain-environment-variable SECRET_ENV_VAR
function keychain-environment-variable () {
    security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

# Use: set-keychain-environment-variable SECRET_ENV_VAR
#   provide: super_secret_key_abc123
function set-keychain-environment-variable () {
    [ -n "$1" ] || print "Missing environment variable name"

    # Note: if using bash, use `-p` to indicate a prompt string, rather than the leading `?`
    read -s "?Enter Value for ${1}: " secret

    ( [ -n "$1" ] && [ -n "$secret" ] ) || return 1
    security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w "${secret}"
}

## Previously run
#set-keychain-environment-variable SAML2AWS_USERNAME
#set-keychain-environment-variable SAML2AWS_PASSWORD

## Write to your zshrc file (or bashrc)
#export SAML2AWS_USERNAME=$(keychain-environment-variable SAML2AWS_USERNAME);
#export SAML2AWS_PASSWORD=$(keychain-environment-variable SAML2AWS_PASSWORD);

function pass-init() {
    set-keychain-environment-variable $1
}

function pass-get() {
    keychain-environment-variable $1;
}

function formatjsonlog() {
  while read -r data; do
    printf "%s" "$data" | jq -r '.["@timestamp"][11:22] + " " + .level + " " + .message + "\n" + .error.stack'
  done
}

function resetipv6() {
    networksetup -listallhardwareports | awk '/Hardware Port: .*Ethernet/ {p=1} p && /Device:/ {print $2; p=0}' | while read dev; do
        echo "Disabling IPv6 on $dev"
        networksetup -setv6off "$dev"
        ifconfig "$dev" | grep inet6
    done
}

function openSession () {
    WORK_DIR="~/dotfiles/"
    SESSION="works"

    tmux kill-session -t $SESSION
    tmux new-session -d -s $SESSION

    # ManoMano session
    tmux split-window -h -t $SESSION:1.1
    tmux send-keys -t $SESSION:1.1 "cd $WORK_DIR && vim $WORK_DIR" Enter
    tmux send-keys -t $SESSION:1.2 "cd $WORK_DIR && ll" Enter
    tmux rename-window 'Dotfiles'

    # MSF Seller Orders session
    WORK_DIR="~/ManoMano/msf-seller-orders"
    tmux new-window -t $SESSION:2 -n 'MSF Seller Orders'
    tmux split-window -h -t $SESSION:2.1
    tmux split-window -v -t $SESSION:2.2
    tmux send-keys -t $SESSION:2.1 "cd $WORK_DIR && vim notes" Enter
    tmux send-keys -t $SESSION:2.1 "G" Enter
    tmux send-keys -t $SESSION:2.3 "cd $WORK_DIR && ll" Enter

    WORK_DIR="/Volumes/ManoMano"
    tmux new-window -t $SESSION:3 -n 'ManoMano Home Directory'
    tmux split-window -h -t $SESSION:3.1
    tmux split-window -v -t $SESSION:3.2
    tmux send-keys -t $SESSION:3.1 "cd $WORK_DIR && vim notes" Enter
    tmux send-keys -t $SESSION:3.1 "G" Enter
    tmux send-keys -t $SESSION:3.2 "cd $WORK_DIR && ll" Enter
    tmux send-keys -t $SESSION:3.3 "cd $WORK_DIR && ll" Enter

    # Attach the session
    tmux attach-session -t $SESSION
}

function tm() {
    SESSION="StarK"

    WORK_DIR="$HOME/Repositories/ManoMano"
    tmux kill-session -t $SESSION
    tmux new-session -d -s $SESSION -n 'Dotfiles'
    tmux send-keys -t $SESSION:1 "cd $HOME/dotfiles && ll" Enter

    tmux new-window -t $SESSION:2 -n 'ManoMano'
    tmux send-keys -t $SESSION:2 "cd $WORK_DIR && ll" Enter

    tmux new-window -t $SESSION:3 -n 'Custom'
    tmux send-keys -t $SESSION:3 "cd $HOME/Desktop && ll" Enter

    # Attach the session
    tmux attach-session -t $SESSION
}

qbrew() {
    HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 HOMEBREW_NO_INSTALL_UPGRADE=1 brew $@
}

daily() {
    cd $HOME/ManoMano/meeting-notes
    vim daily.md
}

pull_all_project() {
    # Define the directory containing your git projects
    projects_dir=$PWD

    # Loop through each directory in the projects_dir
    for dir in "$projects_dir"/*; do
      if [ -d "$dir/.git" ]; then
        echo "Updating project in $dir"
        cd "$dir"
        git pull --rebase --autostash
      else
        echo "Skipping $dir, not a git repository"
      fi
    done
}

crackzip() {
    fcrackzip -b -v -l 1-8 -c a1 -u $1
}

runmysql() {
    docker run --name mysql --platform linux/x86_64 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -v $HOME/Sites/docker/mysql/data_folder:/var/lib/mysql -p 3306:3306 -d mysql:5.7
}

func calculate_taxes() {
    echo "🏃 CD Into taxes folder"
    cd $HOME/dotfiles/tools/DanTaxes

    # current year
    year=$(date +"%Y")
    echo "📂 Generate JPG file from PDF Salary"
    pdftoppm -jpeg dan-$year.pdf files/salary-

    echo "📄 Fetch all Amount to Deduct from taxes ..."
    go run main.go #> search.txt
    #value=$(cat search.txt | sed 's/ //g' | tr '\n' '+' | sed 's/+$//' | bc)

    rm -rf $HOME/dotfiles/tools/DanTaxes/files/sala*
}

func cjq() {
    echo '' | fzf --print-query --preview "cat $1 | jq {q}"
}

a() {
    gemini -p "Only answer with the command. Don't put it in backticks or any markdown. Give me a terminal command to $*" 2>/dev/null
}

func vaultcp() {
    if [ $# -ne 2 ]; then
        echo "Usage: vaultcp <env> <path>"
        return 1
    fi

    local env=$1
    local kvPath=$2
    local role="order"

    # Authenticate only if needed
    if ! VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault token lookup -format=json > /dev/null 2>&1; then
        VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault login -path=sso -method=oidc role="$role"
    fi

    local json=$(VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault kv get -format=json "${env}/${kvPath}" | jq '.data.data')

    # Use printf to safely handle JSON data and escape necessary characters
    local previewCmd=$(printf "echo '%s' | jq --raw-output .\\\"{}\\\"" "$json")
    local bindCmd=$(printf "echo '%s' | jq --raw-output --join-output .\\\"{}\\\" | xclip" "$json")

    # Use echo to pass the JSON keys to fzf, preview and bind must handle complex commands properly
    echo "$json" | jq -r 'keys[]' | fzf --preview "$previewCmd" --bind "enter:execute($bindCmd)"
}
