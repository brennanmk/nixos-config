{ inputs, ... }: 
{
  imports = [ (import ./hyprland.nix) ]
    ++ [ (import ./config.nix) ]
    ++ [ (import ./hyprlock.nix) ]
    ++ [ (import ./hypridle.nix) ]
    ++ [ (import ./variables.nix) ];
}
