#!/usr/bin/env bash
#
# org-capture — pop a small Emacs frame running org-capture from anywhere.
#
# Bound to SUPER+SHIFT+N in Hyprland. Talks to the running `emacs --daemon`
# (starts one if none is running). The frame carries name/param "org-capture"
# so Hyprland floats + centers it (see hyprland config.nix windowrule), and
# init.el's `org-capture-after-finalize-hook` deletes the frame once the
# capture is filed or aborted.

exec emacsclient -a '' -c \
  -F '((name . "org-capture") (my-org-capture-frame . t) (width . 100) (height . 16))' \
  -e '(my/org-capture-frame)'
