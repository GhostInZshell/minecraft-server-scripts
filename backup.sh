#!/bin/bash

SRC="$HOME/paper_minecraft"
DEST="$HOME/paper_backups_duplicity"
TS=$(date +'%Y-%m-%d_%H-%M-%S')

echo "[*] Starting backup at $TS..."

duplicity --no-encryption --progress backup "$SRC" file://"$DEST"

echo "[*] Removing backups older than 90 days..."

duplicity remove-older-than 90D --force --no-encryption --progress file://"$DEST"

echo "[✓] Backup complete."
