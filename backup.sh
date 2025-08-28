#!/bin/bash
###### This file is version controlled in git ######

# Colors
YLW="\e[33m"
GRN="\e[32m"
RED="\e[31m"
CYN="\e[36m"
BLD="\e[1m"
RESET="\e[0m"

SRC="$HOME/paper_minecraft"
DEST="$HOME/paper_backups_duplicity"
TS=$(date +'%Y-%m-%d_%H-%M-%S')

echo "[${YLW}*${RESET}] Starting backup at $TS..."

duplicity --no-encryption --progress backup "$SRC" file://"$DEST"

echo "[${YLW}*${RESET}] Removing backups older than 90 days..."

duplicity remove-older-than 90D --force --no-encryption --progress file://"$DEST"

echo "[${GRN}✓${RESET}] Backup complete."