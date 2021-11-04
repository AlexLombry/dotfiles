#!/bin/sh
pwd="$(pwd)/"

folders=$( ls -1 -d .config/* )
for folder in $folders ; do
    unlink ~/$folder
    ln -s $pwd$folder ~/$folder
done

files=$( ls -1 -A files )
for file in $files ; do
    p="$(pwd)/files/"
    unlink ~/$file
    ln -s $p$file ~/$file
done
