{inputs, username, host, ...}: {
  imports =
    [(import ./git.nix)]                      
    ++ [(import ./gtk.nix)]                       # gtk theme
    ++ [(import ./kitty.nix)]                     # terminal
    ++ [(import ./packages.nix)]                  # other packages
    ++ [(import ./zsh.nix)]
    ++ [(import ./rofi.nix)]
    ++ [(import ./vscodium.nix)]
    ++ [(import ./aspell.nix)];
}
