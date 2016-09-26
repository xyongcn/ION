#!/bin/sh
tmux new-session -d -s 9nodes
tmux split-window -h -p 67
tmux split-window -h
tmux select-pane -t %0
tmux split-window -v -p 67
tmux split-window -v
tmux select-pane -t %1
tmux split-window -v -p 67
tmux split-window -v
tmux select-pane -t %2
tmux split-window -v -p 67
tmux split-window -v

tmux attach