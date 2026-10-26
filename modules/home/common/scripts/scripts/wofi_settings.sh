#!/usr/bin/env bash
#
# A simple, self-contained settings menu using wofi.

# Use an associative array to map menu labels to shell commands.
declare -A commands

# --- Define Menu Items ---

# System & Connectivity
commands["  Network"]="kitty --class floating --override color0=#1e1e2e -e nmtui &"
commands["󰂰  Bluetooth"]="kitty --class floating -e bluetuith &"
commands["󱋆  Display Settings"]="kitty --class floating -e hyprmon-apply &"
commands["  Audio Control"]="kitty --class floating -e pulsemixer"

# Caffeinate toggle
if pgrep -x hypridle > /dev/null; then
    commands["  Caffeinate"]="caffeinate"
else
    commands["  Decaffeinate"]="caffeinate"
fi

# -------------------------

# Get the list of menu labels (the array keys) for wofi.
wofi_options=$(printf "%s\n" "${!commands[@]}")

# Show the wofi menu and capture the user's choice.
selected_label=$(echo -e "$wofi_options" | wofi --dmenu --prompt="Settings:")

# If the user made a selection, run the command.
if [[ -n "$selected_label" ]]; then
    command_to_run="${commands["$selected_label"]}"
    eval "$command_to_run"
fi
