#!/bin/bash
###### This file is version controlled in git ######

# Colors
YLW="\e[33m"
GRN="\e[32m"
RED="\e[31m"
CYN="\e[36m"
BLD="\e[1m"
RST="\e[0m"

if ! command -v duplicity &> /dev/null; then
    echo -e "${BLD}${RED}duplicity not installed, skipping backup.${RST}"
    exit 1
fi

SRC="$HOME/paper_minecraft"
DEST="$HOME/paper_backups_duplicity"
TS=$(date +'%Y-%m-%d_%H-%M-%S')

if [[ ! -d "$DEST" ]]; then
    echo -e "${BLD}${YLW}Backup destination $DEST not found, creating...${RST}"
    mkdir -p "$DEST"
fi

echo -e "${BLD}${CYN}[${YLW}*${CYN}] Starting backup at $TS...${RST}"

duplicity --no-encryption --progress --allow-source-mismatch "$SRC" file://"$DEST"

echo -e "${BLD}${CYN}[${YLW}*${CYN}] Removing backups older than 90 days...${RST}"

duplicity remove-older-than 90D --force --no-encryption --progress --allow-source-mismatch file://"$DEST"

echo -e "${BLD}${CYN}[${GRN}✓${CYN}] Backup complete.${RST}"
