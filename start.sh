#!/usr/bin/env bash

# Get latest paper jar
PAPER_JAR=$(ls -1r paper-* | head -1)

# Trap INT signal to stop server loop
trap 'echo "Stopping server loop..."; exit 0' INT

echo "Detected JAR: $PAPER_JAR"

# Log server start
echo "$(date '+%Y-%m-%d %H:%M:%S') - Server started..." >> server-restarts.log

# Run server loop
while true; do
    java \
	-Xms2G \
  	-Xmx3G \
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
