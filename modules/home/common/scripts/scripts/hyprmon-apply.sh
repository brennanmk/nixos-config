#!/usr/bin/env bash
# hyprmon persists layouts to hyprmon.lua fine, but its live-apply still
# shells out to `hyprctl keyword monitor ...`, which Hyprland rejects on a
# native Lua config ("keyword can't work with non-legacy parsers. Use
# eval."). No fix upstream as of hyprmon v0.0.17 (github.com/erans/hyprmon).
# Run hyprmon normally, then force a live re-apply of whatever it just saved
# via `hyprctl eval` instead.

hyprmon "$@"
hyprctl eval 'dofile(os.getenv("HOME") .. "/.config/hypr/hyprmon.lua")' >/dev/null
