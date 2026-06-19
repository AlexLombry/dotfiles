# System & Utilities Helpers

command_exists() {
    command -v "$@" >/dev/null 2>&1
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
    export BACKGROUND="light" && rld
}

dark() {
    export BACKGROUND="dark" && rld
}

# Better tree functionality
tre() {
    tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Use Preview to open a man page
manp() {
    man -t $1 | open -f -a /Applications/Preview.app
}

# kill all instances of a process by name
skill() {
    sudo pkill -9 "$1"
}

fixperms(){
    find . \( -name "*.sh" -or -type d \) -exec chmod 755 {} \; && find . -type f ! -name "*.sh" -exec chmod 644 {} \;
}

compresspdf() {
    gs -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH -dPDFSETTINGS=/${3:-"screen"} -dCompatibilityLevel=1.4 -sOutputFile="$2" "$1"
}

# Send my public SSH key to another machine
copysshkey () {
    cat ~/.ssh/id_rsa.pub | ssh $1 'cat >> .ssh/authorized_keys'
}

# Create a data URL from a file
dataurl() {
    local mimeType=$(file -b --mime-type "$1");
    if [[ $mimeType == text/* ]]; then
        mimeType="${mimeType};charset=utf-8";
    fi
    echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
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
    local CUR_FILE="$1"
    openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -salt -in "$CUR_FILE" -out "$CUR_FILE.enc"
}

ssldec() {
    local CUR_FILE="$1"
    local STRIP="${CUR_FILE%.enc}"
    openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -in "$CUR_FILE" -out "$STRIP"
}

arc() {
    tar -zcvf "$1.tar.gz" "$1"
}

unarc() {
    tar -xvf "$1"
}

pw () {
    pwgen -sync "${1:-48}" -1 | if command -v pbcopy > /dev/null 2>&1; then pbcopy; else xclip; fi
}

resetipv6() {
    networksetup -listallhardwareports | awk '/Hardware Port: .*Ethernet/ {p=1} p && /Device:/ {print $2; p=0}' | while read dev; do
        echo "Disabling IPv6 on $dev"
        networksetup -setv6off "$dev"

        ifconfig "$dev" | grep inet6
    done
}


qbrew() {
    HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 HOMEBREW_NO_INSTALL_UPGRADE=1 brew $@
}

crackzip() {
    fcrackzip -b -v -l 1-8 -c a1 -u $1
}

a() {
    gemini -p "Only answer with the command. Don't put it in backticks or any markdown. Give me a terminal command to $*" 2>/dev/null
}

pass-init() {
    [ -n "$1" ] || print "Missing environment variable name"

    # Note: if using bash, use `-p` to indicate a prompt string, rather than the leading `?`
    read -s "?Enter Value for ${1}: " secret

    ( [ -n "$1" ] && [ -n "$secret" ] ) || return 1
    security add-generic-password -U -a ${USER} -D "environment variable" -s "${1}" -w "${secret}"
}

pass-get() {
    security find-generic-password -w -a ${USER} -D "environment variable" -s "${1}"
}

# Extract archives - use: extract <file>
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz)  tar xzf $1 ;;
            *.bz2)     bunzip2 $1 ;;
            *.rar)     rar x $1 ;;
            *.gz)      gunzip $1 ;;
            *.tar)     tar xf $1 ;;
            *.tbz2)    tar xjf $1 ;;
            *.tgz)     tar xzf $1 ;;
            *.zip)     unzip $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
