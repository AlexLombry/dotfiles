# Dotfiles

The purpose of this repository is to install a new macOS machine without any effort.

## macOS Setup 
The installation script (install.sh) will install all the necessary program you need like Brew, Zsh and configuring macOS with my own preferences.

The installer launch also the installation of [Go Task](https://github.com/go-task/task) which is used to create some bash script in a Yaml format.

To simply install the script run the following command : 
```
curl https://raw.githubusercontent.com/AlexLombry/dotfiles/master/init.sh | bash
```

### What's going on
If you run the init.sh script, this is what's going to happened.

1. Clone this repository into the ~/dotfiles folder
2. Install the macOS Command Line Tools and accept the licence agreement
3. Install Homebrew
4. Install Go task
5. Setup the macOS preferences
6. Install [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started)
7. Install every application found on the BrewBundle file
8. Generate symlinks for file like .vimrc, zshrc ...
9. Install Python
10. Install Docker

Every command can also be runned one by one with Go Task without running the install.sh. For this you need to have Brew and Go Task installed.

Simply run the command `task --list`

Your Mac is now ready! :smile:

