#!/usr/bin/env bash
source ~/dotfiles/zsh/functions.zsh

ZSH=${ZSH:-~/.oh-my-zsh}

function xcodetools() {
    running "XCode Command Line Tools"
    if [ $(xcode-select -p &> /dev/null; printf $?) -ne 0 ]; then
        xcode-select --install &> /dev/null
        # Wait until the XCode Command Line Tools are installed
        while [ $(xcode-select -p &> /dev/null; printf $?) -ne 0 ]; do
            sleep 5
        done
        xcode-select -p &> /dev/null
        if [ $? -eq 0 ]; then
            # Prompt user to agree to the terms of the Xcode license
            # https://github.com/alrra/dotfiles/issues/10
           sudo xcodebuild -license
       fi
    fi
}

function brewbundle() {
    # Prompt for user choice on running brew bundle command
    action "${YELLOW}Do you want to run Brew Bundle ? [Y/n]${RESET} "
    read opt
    case $opt in
        y*|Y*|"") running "Running brew bundle" && HOMEBREW_NO_AUTO_UPDATE=1 brew bundle ;;
        n*|N*) echo "Brew bundle skipped."; ;;
        *) echo "Invalid choice. Action skipped."; ;;
    esac
}

function docker_install() {
    curl -O https://download.docker.com/mac/stable/Docker.dmg $HOME/Downloads/Docker.dmg
    hdiutil attach -nobrowse $HOME/Downloads/Docker.dmg
    rsync -a /Volumes/Docker/Docker.app /Applications/
    hdiutil detach -quiet /Volumes/Docker
}

function main() {
    setup_color
    xcodetools

    # Install HomeBrew
    if ! command_exists brew; then
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        # Needed for the rest
        HOMEBREW_NO_AUTO_UPDATE=1 brew install go-task/tap/go-task
    fi

    task "os"
    task "zsh"
    brewbundle
    task "links"

    running "Running Task !\n"
    task --list
    $(brew --prefix)/opt/fzf/install
    ok

    running "Installing Python"
    curl https://bootstrap.pypa.io/get-pip.py -o "$HOME/Downloads/get-pip.py"
    python "$HOME/Downloads/get-pip.py" --user
    ok

    running "Installing Docker"
    docker_install
    ok

    running "Fixing fonts"
    sudo chmod 775 ~/Library/Fonts/**/
    ok
}

main "$@"
