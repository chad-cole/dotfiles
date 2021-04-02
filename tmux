#!/usr/bin/env bash

WORK="~/work"

createWindow() {
    session=$1
    window=$2
    shift
    shift
    hasWindow=$(tmux list-windows -t $session | grep "$window")
    if [ -z "$hasWindow" ]; then
        cmd="tmux neww -t $session: -n $window -d"
        if [ $# -gt 0 ]; then
            cmd="$cmd $@"
        fi
        echo "Creating Window(\"$hasWindow\"): $cmd"
        eval $cmd
    fi
}

createSession() {
    session=$1
    window=$2
    shift
    shift
    cmd="tmux new -s $session -d -n $window $@ > /dev/null 2>&1"

    echo "Creating Session: $cmd"
    eval $cmd
}

while [ "$#" -gt 0 ]; do
    curr=$1
    shift

    case "$curr" in
    "-w")
        createSession work primary -c $WORK nvim
        createWindow work shop -c $WORK/shop nvim
        tmux split-window -t work:primary -p 35 -h
        tmux split-window -t work:shop -p 35 -h
        tmux attach -t work
        ;;
    *) echo "Unavailable command... $curr"
    esac
done
