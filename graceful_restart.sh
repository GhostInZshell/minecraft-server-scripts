#!/bin/bash
###### This file is version controlled in git ######

SESSION="minecraft"
PANE="$SESSION:0.0"

# Function to send a command to the tmux session
send_to_minecraft() {
    tmux send-keys -t "$PANE" "$1" C-m
}

# Check if session exists
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Error: tmux session '$SESSION' not found."
    exit 1
fi

# Countdown broadcasts
send_to_minecraft 'tellraw @a {"text":"Server will restart in 5 minutes! Please find a safe spot.","color":"gold","bold":true}'
sleep 240  # 4 minutes

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
