{inputs, username, host, ...}: {
  imports =
    [(import ./git.nix)]      
    ++ [(import ./gtk.nix)]                       # gtk theme
    ++ [(import ./kitty.nix)]                     # terminal
    ++ [(import ./packages.nix)]                  # other packages
    ++ [(import ./zsh.nix)]
    ++ [(import ./rofi.nix)]
    ++ [(import ./aspell.nix)]
    ++ [(import ./hyprland)]                       # window manager    
    ++ [(import ./swaync/swaync.nix)]             # notification deamon
    ++ [(import ./scripts/scripts.nix)]           # personal scripts
    ++ [(import ./waybar)];                        # status bar
}
