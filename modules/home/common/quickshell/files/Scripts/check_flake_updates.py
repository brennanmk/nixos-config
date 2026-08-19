#!/usr/bin/env python3
import json
import os
import subprocess

FLAKE_LOCK = os.path.expanduser("~/nixos-config/flake.lock")


def main():
    try:
        with open(FLAKE_LOCK) as f:
            lock = json.load(f)
    except Exception as e:
        print(json.dumps({"outdated": [], "count": 0, "error": str(e)}))
        return

    nodes = lock.get("nodes", {})
    # Only the top-level inputs declared directly in flake.nix, not every
    # transitive dependency (e.g. hyprland's own nixpkgs/hyprutils pins).
    top_level = nodes.get("root", {}).get("inputs", {})
    outdated = []

    for name, node_key in top_level.items():
        node = nodes.get(node_key, {})
        original = node.get("original", {})
        locked = node.get("locked", {})
        if original.get("type") != "github" or locked.get("type") != "github":
            continue

        owner = original.get("owner")
        repo = original.get("repo")
        rev = locked.get("rev")
        ref = original.get("ref")
        if not (owner and repo and rev):
            continue

        url = f"https://github.com/{owner}/{repo}"
        try:
            result = subprocess.run(
                ["git", "ls-remote", url, ref or "HEAD"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            latest = result.stdout.split()[0] if result.stdout.strip() else None
        except Exception:
            latest = None

        if latest and latest != rev:
            outdated.append(name)

    print(json.dumps({"outdated": sorted(outdated), "count": len(outdated)}))


if __name__ == "__main__":
    main()
