#!/usr/bin/env bash

newWindow() {
    path=$1
    name=$2
    up=$3

    tmux_new_window_cmd="new-window -n $name \; \
        send-keys \"cd $path && cls && nvim\" C-m \; \
        split-window -p 20 -h \; \
        send-keys \"cd $path && cls && [[ ! -z $up ]] && dev up && cls\" C-m \; \
        split-window -p 90 -v \; \
        send-keys \"cd $path && cls\" C-m \; "
    echo $tmux_new_window_cmd
}

tmux_session_create="tmux new-session -s Shop -d \; "
tmux_session_create="$tmux_session_create $(newWindow ~/src/github.com/Shopify/pay Pay true)"
tmux_session_create="$tmux_session_create $(newWindow ~/src/github.com/Shopify/shop-accounts Accounts)"
tmux_session_create="$tmux_session_create $(newWindow ~/src/github.com/Shopify/arrive-server Arrive true)"
tmux_session_create="$tmux_session_create $(newWindow ~/src/github.com/Shopify/shop-docs Docs true)"
tmux_session_create="$tmux_session_create kill-window -t 1 \; move-window -r"

tmux_tophat_session_create="tmux new-session -s Tophat -d \; "
tmux_tophat_session_create="$tmux_tophat_session_create $(newWindow ~/src/github.com/Shopify/shop-charlinho Charlinho true)"
tmux_tophat_session_create="$tmux_tophat_session_create kill-window -t 1 \; move-window -r"

#echo $tmux_session_create
eval "$tmux_session_create"
eval "$tmux_tophat_session_create"

tmux attach -t Shop:1
