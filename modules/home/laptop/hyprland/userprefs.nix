{ lib, ... }:
{
  # Seeded once, then left alone: Minflair's Settings app (Effects tab)
  # rewrites ~/.config/hypr/userprefs.lua in place at runtime, so this must
  # NOT be a home-manager-managed symlink (that would be read-only and the
  # write-back would fail). We only drop the seed if the file is missing.
  home.activation.seedHyprUserprefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    prefs="$HOME/.config/hypr/userprefs.lua"
    if [ ! -e "$prefs" ]; then
      install -Dm644 ${./userprefs.lua} "$prefs"
    fi
  '';
}
