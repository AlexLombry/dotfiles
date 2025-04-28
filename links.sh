#!/bin/bash
# pwd="$(pwd)/"
#
# folders=$( ls -1 -d .config/* )
# for folder in $folders ; do
#     unlink ~/$folder
#     ln -s $pwd$folder ~/$folder
# done
#
# files=$( ls -1 -A files )
# for file in $files ; do
#     p="$(pwd)/files/"
#     unlink ~/$file
#     ln -s $p$file ~/$file
# done
#

# Get the absolute base directory
BASE_DIR="$(pwd)"

# Create symbolic links for each directory inside .config
# Remove the existing one and create the new symbolic link
for folder in .config/*; do
    target="$HOME/$(basename "$folder")"
    rm -rf "$target"
    ln -s "$BASE_DIR/$folder" "$target"
done

# Create symbolic links for each file inside the "files" directory
# Remove existing and create new one
for file in files/*; do
    target="$HOME/$(basename "$file")"
    rm -f "$target"
    ln -s "$BASE_DIR/$file" "$target"
done

