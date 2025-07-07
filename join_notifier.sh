#!/bin/bash

# Adjust path to your actual Paper server's log file
LOG_FILE="$HOME/paper_minecraft/logs/latest.log"

clear
echo "===== Minecraft Server Joins ====="

tail -n0 -F "$LOG_FILE" 2>/dev/null | \
grep --line-buffered "joined the game" | \
while read -r line; do
    player=$(echo "$line" | awk '{print $4}')

    # print to screen
    echo "$player joined at $(date "+%F %T")"

    # send to Discord
    curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\":\"$player joined the Minecraft server!\"}" \
	"$DISCORD_WEBHOOK"
done
