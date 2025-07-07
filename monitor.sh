#!/bin/bash

LOGFILE="$HOME/minecraft_usage.log"

# ANSI color codes
RESET="\e[0m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"

# Print header to log file if it doesn't exist
if [ ! -f "$LOGFILE" ]; then
    echo "Timestamp, CPU (%), Mem Used (MB), Mem Used (%), Swap Used (MB), Java Mem Usage (MB), Disk Usage (%)" >> "$LOGFILE"
fi

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

    # CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

    # Memory stats
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_USED_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")

    # Swap
    SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

    # Java memory usage
    JAVA_MEM=$(ps aux | grep "[j]ava" | awk '{sum+=$6} END {print sum/1024}')  # MB

    # Disk usage (root)
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')           # e.g., "45%"
    DISK_USED_PERCENT=$(echo "$DISK_USAGE" | tr -d '%')     # remove percent sign

    # Color-code CPU
    if (( $(echo "$CPU_USAGE < 70" | bc -l) )); then
        CPU_COLOR=$GREEN
    elif (( $(echo "$CPU_USAGE >= 70" | bc -l) && $(echo "$CPU_USAGE < 90" | bc -l) )); then
        CPU_COLOR=$YELLOW
    else
        CPU_COLOR=$RED
    fi

    # Color-code Memory
    if (( $(echo "$MEM_USED_PERCENT < 70" | bc -l) )); then
        MEM_COLOR=$GREEN
    elif (( $(echo "$MEM_USED_PERCENT >= 70" | bc -l) && $(echo "$MEM_USED_PERCENT < 90" | bc -l) )); then
        MEM_COLOR=$YELLOW
    else
        MEM_COLOR=$RED
    fi

    # Color-code Disk
    if (( DISK_USED_PERCENT < 70 )); then
        DISK_COLOR=$GREEN
    elif (( DISK_USED_PERCENT >= 70 && DISK_USED_PERCENT < 90 )); then
        DISK_COLOR=$YELLOW
    else
        DISK_COLOR=$RED
    fi

    # Log to file
    echo "$TIMESTAMP, $CPU_USAGE, $MEM_USED, $MEM_USED_PERCENT, $SWAP_USED, $JAVA_MEM, $DISK_USAGE" >> "$LOGFILE"

    # Print to screen
    clear
    echo "===== Minecraft Server Monitoring ====="
    echo -e "Timestamp:    $TIMESTAMP"
    echo -e "CPU Usage:    ${CPU_COLOR}$CPU_USAGE%${RESET}"
    echo -e "Memory Used:  ${MEM_COLOR}$MEM_USED MB  ($MEM_USED_PERCENT%)${RESET}"
    echo -e "Swap Used:    $SWAP_USED MB"
    echo -e "Java Memory:  $JAVA_MEM MB"
    echo -e "Disk Usage:   ${DISK_COLOR}$DISK_USAGE${RESET}"
    echo "======================================="

    sleep 30
done
