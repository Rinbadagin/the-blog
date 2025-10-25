#!/bin/bash

# Name of the tmux session
SESSION_NAME="prod_blog"
export BLOG_DIRECTORY="update this"

# Start a new tmux session
tmux new-session -d -s $SESSION_NAME

tmux set -g default-shell /bin/bash
# First window (index 0)
# First pane: cd into blog directory and start Rails server
tmux send-keys -t $SESSION_NAME:0.0 "bash" C-m
tmux send-keys -t $SESSION_NAME:0.0 "cd $BLOG_DIRECTORY" C-m
tmux send-keys -t $SESSION_NAME:0.0 "RAILS_ENV=production bin/rails server" C-m

# Attach to the session
tmux attach-session -t $SESSION_NAME
