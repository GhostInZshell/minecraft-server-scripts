#!/bin/bash
###### This file is version controlled in git ######

# Colors
YLW="\e[33m"
GRN="\e[32m"
RED="\e[31m"
CYN="\e[36m"
BLD="\e[1m"
RST="\e[0m"

# Check duplicity is installed
if ! command -v duplicity &> /dev/null; then
    echo -e "${RED}[x] duplicity not installed. Exiting.${RST}"
    exit 1
fi

# Check backup source exists
if [[ ! -d "$HOME/paper_backups_duplicity" ]]; then
    echo -e "${RED}[x] Backup source $HOME/paper_backups_duplicity not found. Exiting.${RST}"
    exit 1
fi

SRC="file://$HOME/paper_backups_duplicity"
DEST="$HOME/paper_minecraft"
TS=$(date +'%Y-%m-%d_%H-%M-%S')

echo -e "${CYN}${BLD}Restore to original server directory [$DEST]? (Y/n):${RST}"
read -r confirm
confirm=${confirm:-y}

if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo -e "${CYN}${BLD}Enter alternate restore destination (e.g., ./test_restore):${RST}"
    read -r DEST
fi

# Validate DEST path
if ! mkdir -p "$DEST" 2>/dev/null; then
    echo -e "${RED}[x] Failed to create or access destination: $DEST${RST}"
    exit 1
fi

# Extract restore timestamps into an array using robust AWK pattern
echo -e "${CYN}[*] Fetching available backup sets...${RST}"
mapfile -t RESTORE_TIMES < <(duplicity collection-status "$SRC" | awk '$1 ~ /Full|Incremental/ {for(i=2;i<=6;++i) printf $i " "; print ""}')

# Show them as numbered options
if [[ ${#RESTORE_TIMES[@]} -eq 0 ]]; then
    echo -e "${RED}[x] No backup sets found. Exiting.${RST}"
    exit 1
fi

echo -e "${CYN}${BLD}Available Restore Points:${RST}"
for i in "${!RESTORE_TIMES[@]}"; do
    printf "${YLW}%d) %s\n${RST}" "$((i+1))" "${RESTORE_TIMES[$i]}"
done

# Prompt user to select one
read -rp "$(echo -e "${CYN}${BLD}Select a restore point (1-${#RESTORE_TIMES[@]}) or press Enter for latest:${RST} ")" choice

# Map to actual timestamp
if [[ -z "$choice" ]]; then
    RESTORE_TIME=""
elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice <= ${#RESTORE_TIMES[@]} )); then
    RESTORE_TIME="${RESTORE_TIMES[$((choice-1))]}"
else
    echo -e "${RED}[x] Invalid selection.${RST}"
    exit 1
fi

echo -e "${YLW}${BLD}DRY RUN: This will simulate restoring files from duplicity.${RST}"
echo -e "${YLW}[*] Target directory: ${RST}$DEST"
echo -e "${YLW}[*] Timestamp: ${RST}${RESTORE_TIME:-latest}"
echo

echo -e "${CYN}${BLD}Proceed with dry run restore? (y/N):${RST}"
read -r proceed
proceed=${proceed:-n}

if [[ "$proceed" =~ ^[Yy]$ ]]; then
    echo -e "${GRN}[*] Performing dry run...${RST}"
    if [[ -z "$RESTORE_TIME" ]]; then
        duplicity --no-encryption --progress --dry-run restore "$SRC" "$DEST"
    else
        duplicity --no-encryption --progress --dry-run restore --time "$RESTORE_TIME" "$SRC" "$DEST"
    fi
    echo -e "${GRN}[✓] Dry run complete at $TS${RST}"
else
    echo -e "${RED}[x] Dry run canceled.${RST}"
fi
