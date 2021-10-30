#!/usr/bin/env bash
source ~/dotfiles/zsh/functions.zsh

running "Install configuration file symlink"

files=$( ls -1 -d config/* )
for file in $files ; do
    pwd="$(pwd)/"
    filename="$(ls $file | cut -d. -f1 | cut -d/ -f2)"
    unlink ~/.$filename
    ln -s $pwd$file ~/.$filename
done
ok
