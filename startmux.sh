#!/bin/bash

# Function to create the Rails development session
create_rails_session() {
    tmux new-session -d -s rails_dev

    # Split the window and run commands
    tmux split-window -v
    tmux select-pane -t 0
    tmux send-keys -t rails_dev:0.0 'rails dartsass:watch' C-m
    tmux select-pane -t 1
    tmux send-keys -t rails_dev:0.1 'rails server' C-m
    tmux select-layout -t rails_dev:0 even-vertical
}

# Check if the session exists
tmux has-session -t rails_dev 2>/dev/null

# If the session doesn't exist, create it
if [ $? != 0 ]; then
    create_rails_session
fi

# Attach to the session
tmux attach-session -t rails_dev
