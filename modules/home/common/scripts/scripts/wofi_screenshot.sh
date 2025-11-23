#!/usr/bin/env bash
#
# A simple, self-contained settings menu using wofi.

# Use an associative array to map menu labels to shell commands.
declare -A commands

# --- Define Menu Items ---

# Screenshot (using hyprshot)
commands["󰹑  Whole screen"]="hyprshot -m output --clipboard-only &"
commands["󰩭  Window / Region"]="hyprshot -m region --clipboard-only &"

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
