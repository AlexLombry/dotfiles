# Colors & UI Helpers
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

# Set macOS default only if it's different
set_default() {
    local domain="$1"
    local key="$2"
    local value="$3"
    local type="${4:--bool}"

    # Handle boolean conversion for comparison
    local compare_value="$value"
    if [[ "$type" == "-bool" ]]; then
        if [[ "$value" == "true" || "$value" == "YES" ]]; then compare_value="1"; fi
        if [[ "$value" == "false" || "$value" == "NO" ]]; then compare_value="0"; fi
    fi

    local current_value=$(defaults read "$domain" "$key" 2>/dev/null)
    if [[ "$current_value" != "$compare_value" ]]; then
        defaults write "$domain" "$key" "$type" "$value"
    fi
}
