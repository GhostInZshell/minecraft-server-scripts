#!/usr/bin/env bash
###### This file is version controlled in git ######

# Colors
YLW="\e[33m"
GRN="\e[32m"
RED="\e[31m"
CYN="\e[36m"
BLD="\e[1m"
RESET="\e[0m"

# Get latest paper jar
PAPER_JAR=$(ls -1 paper-*.jar 2>/dev/null | sort -Vr | head -1)

if [[ -z "$PAPER_JAR" ]]; then
    echo -e "${RED}ERROR: No paper-*.jar found in current directory. Exiting.${RESET}"
    exit 1
fi

echo -e "${RED}Detected JAR: $PAPER_JAR${RESET}"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Detected JAR: $PAPER_JAR" >> server-restarts.log

# Trap INT signal to stop server loop
trap 'echo "Stopping server loop..."; exit 0' INT

# Allocate RAM
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
echo -e "${YLW}Total RAM Detected: $TOTAL_MEM_MB MB${RESET}" | tee -a server-restarts.log

# Leave 600 MB for the OS + overhead
XMX_MB=$((TOTAL_MEM_MB - 600))

# Floor to ensure minimum
if [ "$XMX_MB" -lt 512 ]; then
  XMX_MB=512
fi

# Cap XMX to avoid absurd allocations
if [ "$XMX_MB" -gt 8192 ]; then
  XMX_MB=8192
fi

XMS="512M"
XMX="${XMX_MB}M"

echo -e "${GRN}Allocating: Min $XMS, ${RED}Max $XMX"${RESET} | tee -a server-restarts.log

# Log server start
echo "$(date '+%Y-%m-%d %H:%M:%S') - Server started..." >> server-restarts.log

# Run server loop
while true; do
    # Check for new paper jar
    NEW_JAR=$(ls -1 paper-*.jar 2>/dev/null | sort -Vr | head -1)

    if [[ "$NEW_JAR" != "$PAPER_JAR" ]]; then
        echo -e "${CYN}New Paper JAR detected: ${BLD}$NEW_JAR${RESET}"
        echo -e "${GRN}Upgrading from $PAPER_JAR → $NEW_JAR${RESET}"
        PAPER_JAR="$NEW_JAR"
    fi

    java \
        -Xms$XMS \
        -Xmx$XMX \
        -XX:+AlwaysPreTouch \
        -XX:+DisableExplicitGC \
        -XX:+ParallelRefProcEnabled \
        -XX:+PerfDisableSharedMem \
        -XX:+UnlockExperimentalVMOptions \
        -XX:+UseG1GC \
        -XX:G1HeapRegionSize=8M \
        -XX:G1HeapWastePercent=5 \
        -XX:G1MaxNewSizePercent=35 \
        -XX:G1MixedGCCountTarget=4 \
        -XX:G1MixedGCLiveThresholdPercent=90 \
        -XX:G1NewSizePercent=25 \
        -XX:G1RSetUpdatingPauseTimePercent=5 \
        -XX:G1ReservePercent=20 \
        -XX:InitiatingHeapOccupancyPercent=15 \
        -XX:MaxGCPauseMillis=200 \
        -XX:MaxTenuringThreshold=3 \
        -XX:SurvivorRatio=16 \
        -Dusing.aikars.flags=https://mcflags.emc.gs \
        -Daikars.new.flags=true \
        -jar "$PAPER_JAR" \
        nogui

    ## Run if server stops
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Server stopped." >> server-restarts.log

    # Check disk space before backup
    echo "Checking disk space before backup..."
    df -h /

    read -t 10 -rp "Do you want to run a full backup before restarting? (Y/n) " run_backup

    # Default to 'y' if no input (or if user just hits enter)
    run_backup=${run_backup:-y}

    # Run backup if user wants to
    if [[ "$run_backup" =~ ^[yY]$ ]]; then
        if [[ -f ~/backup.sh ]]; then
            echo "Running backup script..."
            ~/backup.sh
        else
            echo -e "${RED}backup.sh not found, skipping.${RESET}"
        fi
    else
        echo -e "${YLW}Skipping backup.${RESET}"
    fi

    # Log server restart
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Server restarting..." >> server-restarts.log
    for i in {10..1}; do
        echo -ne "Server restarting in $i second(s)... Press CTRL + C to cancel.   \r"
        sleep 1
    done
    echo
done
