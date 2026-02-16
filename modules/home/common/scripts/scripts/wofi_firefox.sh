#!/usr/bin/env bash

query=$(wofi --dmenu --prompt "Search Firefox:" --lines 1)

if [ -n "$query" ]; then
    firefox --search "$query"
fi

