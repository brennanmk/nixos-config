{ self, pkgs, lib, inputs, ...}: 
{
  # imports = [ inputs.nix-gaming.nixosModules.default ];
  nix = {
    settings = {
      download-buffer-size = 536870912;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];

      # Keep build inputs/outputs of dev shells around so GC (and `nix-clean`)
      # doesn't force `nix develop` / direnv projects to rebuild from source.
      keep-outputs = true;
      keep-derivations = true;

      substituters = [
        "https://nix-gaming.cachix.org"
        "https://hyprland.cachix.org"        # hyprland input builds from source otherwise
        "https://nix-community.cachix.org"   # NUR, home-manager, community tooling
        "https://cuda-maintainers.cachix.org" # CUDA/torch — huge and rarely upstream-cached
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    direnv
    devenv
  ];

  environment.variables.PATH = "$PATH:$HOME/.local/bin";
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
  system.stateVersion = "24.05";
}
