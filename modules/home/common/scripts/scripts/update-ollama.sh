#!/usr/bin/env bash
set -euo pipefail

DERIVATION="$HOME/nixos-config/pkgs/ollama-bin.nix"

LATEST=$(curl -sf https://api.github.com/repos/ollama/ollama/releases/latest | jq -r '.tag_name' | sed 's/^v//')
CURRENT=$(grep -oP '(?<=version = ")[^"]+' "$DERIVATION" | head -1)

if [ "$LATEST" = "$CURRENT" ]; then
  echo "ollama-bin: already at $CURRENT, skipping"
  exit 0
fi

echo "ollama-bin: $CURRENT → $LATEST"
URL="https://github.com/ollama/ollama/releases/download/v${LATEST}/ollama-linux-amd64.tar.zst"
HASH=$(nix store prefetch-file --hash-type sha256 --json "$URL" 2>/dev/null | jq -r '.hash')

sed -i "s/version = \"${CURRENT}\";/version = \"${LATEST}\";/" "$DERIVATION"
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"${HASH}\";|" "$DERIVATION"

echo "ollama-bin: pinned to $LATEST ($HASH)"
