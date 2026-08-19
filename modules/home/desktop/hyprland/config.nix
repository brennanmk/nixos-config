{ ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        { output = "DP-2"; mode = "3440x1440@165.00"; position = "1440x0"; scale = "1"; }
        { output = "HDMI-A-1"; mode = "3840x2160"; position = "0x0"; scale = "1.5"; transform = 1; }
        { output = "DP-1"; mode = "3840x2160"; position = "4880x0"; scale = "1.5"; transform = 3; }
      ];

      window_rule = [
        { match.class = "^(floating)$"; float = true; center = true; size = "800 600"; }
        { match.title = "^Minflair Settings$"; float = true; size = "800 500"; center = true; }
        { match.title = "^Minflair Keybinds Cheat Sheet$"; float = true; size = "900 600"; center = true; }
      ];

      layer_rule = [
        { match.namespace = "quickshell"; blur = true; xray = false; ignore_alpha = 0.1; animation = "off"; }
      ];

      env = [
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
        { _args = [ "XCURSOR_THEME" "Nordzy-cursors" ]; }
        { _args = [ "HYPRCURSOR_THEME" "Nordzy-cursors" ]; }
        { _args = [ "QT_QPA_PLATFORMTHEME" "qt5ct" ]; }
        { _args = [ "QS_PRIMARY_MONITOR" "DP-2" ]; } # center monitor: keeps the quickshell bar off DP-1/HDMI-A-1
      ];
    };

    extraLuaFiles = {
      keybinds = {
        content = ./keybinds.lua;
        autoLoad = true;
      };
    };

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("systemctl --user import-environment")
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("hyprctl setcursor Nordzy-cursors 22")
        hl.exec_cmd("poweralertd")
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("sleep 1; awww img \"$HOME/Pictures/wallpapers/wallpaper.jpg\"; mkdir -p \"$HOME/.cache/quickshell\"; echo wallpaper.jpg > \"$HOME/.cache/quickshell/current_wallpaper\"")
        hl.exec_cmd("QT_QPA_PLATFORM=wayland qs")
        hl.exec_cmd("for i in $(seq 1 100); do echo | socat - UNIX-CONNECT:/tmp/quickshell_lockScreen 2>/dev/null && break; sleep 0.05; done")
      end)

      -- Live-editable preferences (Minflair Settings app writes this file
      -- directly; see modules/home/desktop/hyprland/userprefs.nix for the
      -- initial seed). Values here override the equivalent hl.* calls above.
      require("userprefs")
    '';
  };
}
