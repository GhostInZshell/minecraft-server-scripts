#!/bin/bash

SESSION="minecraft"

# Function to send a command to the tmux session
send_to_minecraft() {
    tmux send-keys -t "$SESSION" "$1" C-m
}

# Check if session exists
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Error: tmux session '$SESSION' not found."
    exit 1
fi

# Countdown broadcasts
send_to_minecraft "broadcast §6Server will restart in 5 minutes! §lPlease find a safe spot."
sleep 240  # 4 minutes

send_to_minecraft "broadcast §cServer will restart in 1 minute!"
sleep 50

send_to_minecraft "broadcast §4Server restarting in 10 seconds..."
sleep 5
send_to_minecraft "broadcast §45..."
sleep 1
send_to_minecraft "broadcast §44..."
sleep 1
send_to_minecraft "broadcast §43..."
sleep 1
send_to_minecraft "broadcast §42..."
sleep 1
send_to_minecraft "broadcast §41..."
sleep 1

# Stop the server
send_to_minecraft "stop"
