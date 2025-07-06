#!/usr/bin/env bash

SESSION="minecraft"

# Kill existing session cleanly
tmux kill-session -t "$SESSION" 2>/dev/null

# Create the session and first window
tmux new-session -d -s "$SESSION" -n "Minecraft"

# Pane 0 (left): Minecraft server
tmux send-keys -t "$SESSION":0.0 'cd ~/paper_minecraft && ./start.sh' C-m

# Split right vertically to create pane 1
tmux split-window -h -t "$SESSION":0.0

# Split pane 1 into 3 horizontal sections (panes 1, 2, and 3)
tmux split-window -v -t "$SESSION":0.1
tmux split-window -v -t "$SESSION":0.1

# Pane 1 (top right): monitor script
tmux send-keys -t "$SESSION":0.1 'cd ~ && ./monitor_minecraft.sh' C-m

# Pane 2 (middle right): join notifier
tmux send-keys -t "$SESSION":0.2 'cd ~ && ./join_notifier.sh' C-m

# Pane 3 (bottom right): leave empty
# (optional: you could run a log tail, shell, or htop here)

# Focus left pane (optional)
tmux select-pane -t "$SESSION":0.0

# (Optional) Attach to the session automatically
tmux attach-session -t "$SESSION"
