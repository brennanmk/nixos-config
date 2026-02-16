#!/usr/bin/env bash
#
# Capture menu - screenshots and screen recording.

declare -A commands

# Screenshots
commands["󰹑  Screenshot: Whole Screen"]="hyprshot -m output --clipboard-only &"
commands["󰩭  Screenshot: Region"]="hyprshot -m region --clipboard-only &"

# Recording
commands["󰻞  Record: Full Screen"]="record screen &"
commands["󰿎  Record: Region"]="record area &"
commands["󱎬  Record: GIF"]="record gif &"

# Show stop only when a recording is active
if pgrep -x wf-recorder >/dev/null; then
  commands["󰹊  Stop Recording"]="record stop &"
fi

wofi_options=$(printf "%s\n" "${!commands[@]}")

selected_label=$(echo -e "$wofi_options" | wofi --dmenu --prompt="Capture:")

if [[ -n "$selected_label" ]]; then
    command_to_run="${commands["$selected_label"]}"
    eval "$command_to_run"
fi
