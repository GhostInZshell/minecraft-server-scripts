#!/bin/bash
###### This file is version controlled in git ######

SESSION="minecraft"
PANE="$SESSION:0.0"

# Default countdown in minutes
MINUTES=5

# Parse flags
while getopts "t:" opt; do
    case $opt in
        t) MINUTES="$OPTARG" ;;
        *) echo "Usage: $0 [-t minutes]"; exit 1 ;;
    esac
done

# Function to send a command to the tmux pane
send_to_minecraft() {
    tmux send-keys -t "$PANE" "$1" C-m
}

# Check if session exists
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Error: tmux session '$SESSION' not found."
    exit 1
fi

# Calculate sleep durations
TOTAL_SECONDS=$((MINUTES * 60))
FOUR_MIN_MARK=$((TOTAL_SECONDS - 60))

echo "Graceful restart in $MINUTES minute(s)..."

# Countdown broadcasts
send_to_minecraft "tellraw @a {\"text\":\"Server will restart in $MINUTES minute(s)! Please find a safe spot.\",\"color\":\"gold\",\"bold\":true}"
sleep $FOUR_MIN_MARK

send_to_minecraft 'tellraw @a {"text":"Server will restart in 1 minute!","color":"red","bold":true}'
sleep 50

send_to_minecraft 'tellraw @a {"text":"Server restarting in 10 seconds...","color":"dark_red","bold":true}'
sleep 5
send_to_minecraft 'tellraw @a {"text":"5...","color":"dark_red","bold":true}'
sleep 1
send_to_minecraft 'tellraw @a {"text":"4...","color":"dark_red","bold":true}'
sleep 1
send_to_minecraft 'tellraw @a {"text":"3...","color":"dark_red","bold":true}'
sleep 1
send_to_minecraft 'tellraw @a {"text":"2...","color":"dark_red","bold":true}'
sleep 1
send_to_minecraft 'tellraw @a {"text":"1...","color":"dark_red","bold":true}'
sleep 1

# Stop the server
send_to_minecraft "stop"