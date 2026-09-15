#!/usr/bin/env bash
# emacs-lock — keep straight.el package versions in lockstep with nixos-config.
#
#   emacs-lock freeze   pull latest packages, regenerate the lockfile, copy it
#                       into the repo (commit it to pin those versions)
#   emacs-lock thaw     copy the repo lockfile into place and check every
#                       package out to it (use on a second machine / to revert)
#
# The lockfile lives at configs/common/emacs/straight-versions.el in the repo.
# init.el copies it into straight/versions/default.el on every startup, so a
# plain `nix-switch` + Emacs restart already applies whatever is committed.
set -euo pipefail

EMACS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/emacs"
REPO_LOCK="$HOME/nixos-config/configs/common/emacs/straight-versions.el"
STRAIGHT_LOCK="$EMACS_DIR/straight/versions/default.el"

# Auto-answer straight.el's confirmation prompts under --batch.
NOPROMPT="(cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t)) \
                    ((symbol-function 'yes-or-no-p) (lambda (&rest _) t)))"

if ! command -v emacs >/dev/null 2>&1; then
  echo "emacs-lock: emacs not installed, skipping"; exit 0
fi
if [ ! -d "$EMACS_DIR/straight/repos/straight.el" ]; then
  echo "emacs-lock: straight.el not bootstrapped yet, skipping"; exit 0
fi

case "${1:-freeze}" in
  freeze)
    echo "emacs-lock: pulling straight packages + freezing versions…"
    if ! emacs --batch -l "$EMACS_DIR/init.el" \
         --eval "${NOPROMPT} (straight-pull-all) (straight-freeze-versions t))"; then
      echo "emacs-lock: pull/freeze failed — keeping existing lockfile"
      exit 0
    fi
    if [ -f "$STRAIGHT_LOCK" ]; then
      mkdir -p "$(dirname "$REPO_LOCK")"
      cp "$STRAIGHT_LOCK" "$REPO_LOCK"
      echo "emacs-lock: wrote $REPO_LOCK — commit it to pin these versions"
    fi
    ;;
  thaw)
    if [ ! -f "$REPO_LOCK" ]; then
      echo "emacs-lock: no $REPO_LOCK yet, nothing to thaw"; exit 0
    fi
    mkdir -p "$(dirname "$STRAIGHT_LOCK")"
    cp "$REPO_LOCK" "$STRAIGHT_LOCK"
    emacs --batch -l "$EMACS_DIR/init.el" \
      --eval "${NOPROMPT} (straight-thaw-versions))"
    echo "emacs-lock: packages checked out to repo lockfile"
    ;;
  *)
    echo "usage: emacs-lock [freeze|thaw]" >&2; exit 2
    ;;
esac
