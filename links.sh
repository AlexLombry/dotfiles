#!/usr/bin/env zsh
set -euo pipefail

# Get the absolute base directory
BASE_DIR="$(pwd)"

# Create symbolic links for each directory inside .config
# Only recreate if the symlink does not already point to the correct target
for folder in .config/*; do
    target="$HOME/$(basename "$folder")"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$BASE_DIR/$folder" ]; then
        echo "$target already points to $BASE_DIR/$folder"
    else
        rm -rf "$target"
        ln -s "$BASE_DIR/$folder" "$target"
        echo "Linked $target -> $BASE_DIR/$folder"
    fi
done

# Create symbolic links for each file inside the "files" directory
# Only recreate if the symlink does not already point to the correct target
for file in files/*; do
    target="$HOME/$(basename "$file")"
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$BASE_DIR/$file" ]; then
        echo "$target already points to $BASE_DIR/$file"
    else
        rm -f "$target"
        ln -s "$BASE_DIR/$file" "$target"
        echo "Linked $target -> $BASE_DIR/$file"
    fi
done

