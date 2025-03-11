{inputs, username, host, ...}: {
  imports =
    [(import ./hyprland)]                       # window manager
    ++ [(import ./waybar)];                        # status bar
}
