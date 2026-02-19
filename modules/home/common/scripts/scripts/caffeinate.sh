#!/usr/bin/env bash
# Toggle hypridle to prevent/allow sleep (like macOS caffeinate)

if pgrep -x hypridle > /dev/null; then
    pkill -x hypridle
    notify-send -u normal "☕ Caffeinate" "Sleep inhibited — screen will stay on"
else
    hypridle &
    disown
    notify-send -u normal "😴 Caffeinate Off" "Sleep restored — idle timer active"
fi
