#!/bin/sh
pwd="$(pwd)/"

folders=$( ls -1 -d .config/* )
for folder in $folders ; do
    unlink ~/$folder
    ln -s $pwd$folder ~/$folder
done

files=$( ls -1 -A files )
for file in $files ; do
    unlink ~/$file
    ln -s $pwd$file ~/$file
done
