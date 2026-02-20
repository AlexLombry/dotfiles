#!/bin/zsh

set -e

BACKUP_ROOT="$HOME/mac_backup"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
WORK_DIR="$BACKUP_ROOT/backup_$TIMESTAMP"
ARCHIVE="$BACKUP_ROOT/mac_backup_$TIMESTAMP.tar.gz"
ENCRYPTED_ARCHIVE="$ARCHIVE.gpg"

echo "Création du dossier de travail..."
mkdir -p "$WORK_DIR"

echo "Copie des fichiers..."

# Dotfiles principaux
for file in .zshrc .zprofile .zshenv .gitconfig .gitignore_global; do
  [ -e "$HOME/$file" ] && cp -R "$HOME/$file" "$WORK_DIR"
done

# Dossiers sensibles
for dir in .ssh .gnupg .config .docker .aws .kube; do
  [ -d "$HOME/$dir" ] && echo cp -R "$HOME/$dir" "$WORK_DIR"
done

# Library critique
mkdir -p "$WORK_DIR/Library"
for libdir in "Keychains"; do
  [ -d "$HOME/Library/$libdir" ] && cp -R "$HOME/Library/$libdir" "$WORK_DIR/Library"
done

echo "Création de l'archive..."
tar -czf "$ARCHIVE" -C "$BACKUP_ROOT" "backup_$TIMESTAMP"

echo "Chiffrement avec GPG (AES-256)..."
gpg --symmetric --cipher-algo AES256 --output "$ENCRYPTED_ARCHIVE" "$ARCHIVE"

echo "Suppression des fichiers non chiffrés..."
rm -rf "$WORK_DIR"
rm -f "$ARCHIVE"

echo "Sauvegarde chiffrée créée :"
echo "$ENCRYPTED_ARCHIVE"

## To restore the archive :
# gpg --output backup.tar.gz --decrypt mac_backup_DATE.tar.gz.gpg
# tar -xzf backup.tar.gz
