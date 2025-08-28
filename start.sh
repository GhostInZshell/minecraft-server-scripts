#!/usr/bin/env bash
###### This file is version controlled in git ######

# Get latest paper jar
PAPER_JAR=$(ls -1r paper-* | head -1)

# Trap INT signal to stop server loop
trap 'echo "Stopping server loop..."; exit 0' INT

echo "Detected JAR: $PAPER_JAR"

# Allocate RAM
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
echo "Total RAM Detected: $TOTAL_MEM_MB MB" | tee -a server-restarts.log

# Leave 500 MB for the OS + overhead
XMX_MB=$((TOTAL_MEM_MB - 600))

# Cap XMX to avoid absurd allocations
if [ "$XMX_MB" -lt 512 ]; then
  XMX_MB=512
fi

XMS="512M"
XMX="${XMX_MB}M"

echo "Allocating: Min $XMS, Max $XMX" | tee -a server-restarts.log

# Log server start
echo "$(date '+%Y-%m-%d %H:%M:%S') - Server started..." >> server-restarts.log

# Run server loop
while true; do
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
        echo "Running backup script..."
        ~/backup.sh
    else
        echo "Skipping backup."
    fi

    # Log server restart
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Server restarting..." >> server-restarts.log
    for i in {10..1}; do
        echo -ne "Server restarting in $i second(s)... Press CTRL + C to cancel.   \r"
        sleep 1
    done
    echo
done
