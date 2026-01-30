# Dotfiles

## macOS Setup

The installation script (install/install.sh) will install all the necessary program you need like Brew, Zsh and configuring macOS with my own preferences.

The installer launch also the installation of [Go Task](https://github.com/go-task/task) which is used to create some bash script in a Yaml format.

To install everything on a new Mac, simply run:

```bash
curl -fsSL https://raw.githubusercontent.com/AlexLombry/dotfiles/main/install/init.sh | zsh
```

### What happens under the hood?

1.  **Bootstrap (`init.sh`)**:
    *   Ensures Xcode Command Line Tools are installed.
    *   Clones this repository to `~/dotfiles`.
    *   Executes `install/install.sh`.
2.  **Core Tooling (`install.sh`)**:
    *   Sets Zsh as the default shell.
    *   Installs **Oh My Zsh** (unattended).
    *   Installs **Homebrew**, **Mise**, **Go Task**, and **GNU Stow**.
    *   Hands over the rest to `task setup`.
3.  **Unified Setup (`Taskfile.yml`)**:
    *   **Stow**: Applies symlinks (using `--adopt` to merge existing configs).
    *   **OS**: Configures macOS system preferences.
    *   **Brew**: Installs all apps/tools via `Brewfile`.
    *   **Mise**: Installs language runtimes (Python, Node, etc.).
    *   **Plugins**: Configures specialized tools like NeoVim.

### Modular Control

Every command can also be run individually with Go Task if you already have Brew and Go Task installed.
Simply run `task --list` to see available tasks.

For example, to only refresh symlinks:
```bash
task stow
```

Your Mac is now ready! 😉
