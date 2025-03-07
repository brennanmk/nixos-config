{inputs, username, host, ...}: {
  imports =
    [(import ./hyprland)]                       # window manager
    ++ [ (import ./hyprlock.nix) ]
    ++ [(import ./waybar)];                        # status bar
}
