#!/usr/bin/env zsh
source ~/dotfiles/zsh/alex/functions.zsh

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

function aws_cli_install() {
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm -rf AWSCLIV2.pkg
}

function main() {
    setup_color
    xcodetools

    # Install HomeBrew
    if ! command_exists brew; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Needed for the rest
        HOMEBREW_NO_AUTO_UPDATE=1 brew install go-task/tap/go-task
    fi

    source $HOME/.zshrc

    task "os"
    task "zsh"
    source $HOME/.zshrc

    brewbundle
    task "links"

    running "Running Task !\n"
    task --list
    $(brew --prefix)/opt/fzf/install
    ok

    running "AWS Cli Install"
    aws_cli_install
    ok

    running "Installing Python"
    curl https://bootstrap.pypa.io/get-pip.py -o "$HOME/Downloads/get-pip.py"
    python3 "$HOME/Downloads/get-pip.py" --user
    ok

    running "Fixing fonts"
    sudo chmod 775 ~/Library/Fonts/**/
    ok
}

main "$@"
