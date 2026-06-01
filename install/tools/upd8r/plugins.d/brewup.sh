#!/usr/bin/env bash
PATH="/usr/local/bin:/usr/local/sbin:/Users/${USER}/.local/bin:/usr/bin:/usr/sbin:/bin:/sbin"

## M1 Brew PATH Fix
if [ "$(arch)" = "arm64" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi

## checks if mas, terminal-notifier are installed, if not will promt to install
if [ -z "$(which mas)" ]; then
  brew install mas 2>/dev/null
fi

green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)
brewFileName="Brewfile"

## Sets Working Dir as Script Location
cd "$(dirname "$0")" || exit

echo "${blue}==>${reset} Pulling latest changes from repo..."
git pull 2>&1

## Brew packages update and cleanup
echo "${yellow}==>${reset} Checking for brew updates..."
brew update 2>&1
brew outdated 2>&1
brew upgrade 2>&1
brew cleanup -s 2>&1
echo "${green}==>${reset} Finished brew updates"

## Creating Dump File and committing to repo
brew bundle dump --force --file="./${brewFileName}"

if git diff --quiet "${brewFileName}"; then
  echo "${green}==>${reset} Brewfile unchanged, nothing to commit."
else
  echo "${blue}==>${reset} Committing and pushing Brewfile changes..."
  git add "${brewFileName}"
  git commit -m "chore: update Brewfile [upd8r]"
  git push
  echo "${green}==>${reset} Brewfile pushed to remote."
fi

echo "${green}==>${reset} Finished updating brew packages"
