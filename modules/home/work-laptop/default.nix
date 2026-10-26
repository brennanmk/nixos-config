{ inputs, username, host, ...}: {
  imports = [
    # work-laptop deliberately reuses the laptop home stack (hyprland,
    # waybar, p10k); the machines only diverge below the HM layer.
    ./../laptop
    ./packages.nix
  ];
}
