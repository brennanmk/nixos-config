{inputs, username, host, ...}: {
  imports =
    [(import ./git.nix)]
    ++ [(import ./gtk.nix)]                       # gtk theme
    ++ [(import ./kitty.nix)]                     # terminal
    ++ [(import ./packages.nix)]                  # other packages
    ++ [(import ./zsh.nix)]
    ++ [(import ./swaync/swaync.nix)]             # notification deamon
    ++ [(import ./scripts/scripts.nix)];          # personal scripts
}
