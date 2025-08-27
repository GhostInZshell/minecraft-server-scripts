#!/bin/bash
###### This file is version controlled in git ######

# Colors
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

SRC="file://$HOME/paper_backups_duplicity"
DEST="$HOME/paper_minecraft"
TS=$(date +'%Y-%m-%d_%H-%M-%S')

echo -e "${CYAN}${BOLD}Restore to original server directory [$DEST]? (Y/n):${RESET}"
read -r confirm
confirm=${confirm:-y}

if [[ "$confirm" =~ ^[Nn]$ ]]; then
    echo -e "${CYAN}${BOLD}Enter alternate restore destination (e.g., ./test_restore):${RESET}"
    read -r DEST
fi

# Validate DEST path
if ! mkdir -p "$DEST" 2>/dev/null; then
    echo -e "${RED}[x] Failed to create or access destination: $DEST${RESET}"
    exit 1
fi

# Extract restore timestamps into an array using robust AWK pattern
echo -e "${CYAN}[*] Fetching available backup sets...${RESET}"
mapfile -t RESTORE_TIMES < <(duplicity collection-status "$SRC" | awk '$1 ~ /Full|Incremental/ {for(i=2;i<=6;++i) printf $i " "; print ""}')

# Show them as numbered options
if [[ ${#RESTORE_TIMES[@]} -eq 0 ]]; then
    echo -e "${RED}[x] No backup sets found. Exiting.${RESET}"
    exit 1
fi

echo -e "${CYAN}${BOLD}Available Restore Points:${RESET}"
for i in "${!RESTORE_TIMES[@]}"; do
    printf "${YELLOW}%d) %s\n${RESET}" "$((i+1))" "${RESTORE_TIMES[$i]}"
done

# Prompt user to select one
read -rp "$(echo -e "${CYAN}${BOLD}Select a restore point (1-${#RESTORE_TIMES[@]}) or press Enter for latest:${RESET} ")" choice

# Map to actual timestamp
if [[ -z "$choice" ]]; then
    RESTORE_TIME=""
elif [[ "$choice" =~ ^[1-9][0-9]*$ ]] && (( choice >= 1 && choice <= ${#RESTORE_TIMES[@]} )); then
    RESTORE_TIME="${RESTORE_TIMES[$((choice-1))]}"
else
    echo -e "${RED}[x] Invalid selection.${RESET}"
    exit 1
fi

echo -e "${YELLOW}${BOLD}DRY RUN: This will simulate restoring files from duplicity.${RESET}"
echo -e "${YELLOW}[*] Target directory: ${RESET}$DEST"
echo -e "${YELLOW}[*] Timestamp: ${RESET}${RESTORE_TIME:-latest}"
echo

echo -e "${CYAN}${BOLD}Proceed with dry run restore? (y/N):${RESET}"
read -r proceed
proceed=${proceed:-n}

if [[ "$proceed" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}[*] Performing dry run...${RESET}"
    if [[ -z "$RESTORE_TIME" ]]; then
        duplicity --no-encryption --progress --dry-run restore "$SRC" "$DEST"
    else
        duplicity --no-encryption --progress --dry-run restore --time "$RESTORE_TIME" "$SRC" "$DEST"
    fi
    echo -e "${GREEN}[✓] Dry run complete at $TS${RESET}"
else
    echo -e "${RED}[x] Dry run canceled.${RESET}"
fi
