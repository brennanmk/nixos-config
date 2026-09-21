{
  description = "Brennan's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, self, ...} @ inputs:
  let
    username = "brennan";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      system = system;
      config.allowUnfree = true;
    };

    overlays = [
      (final: prev: {
        ollama-bin = final.callPackage (self + "/pkgs/ollama-bin.nix") { };
        dracula-theme = final.callPackage (self + "/pkgs/dracula-theme.nix") { };
      })
    ];
    lib = nixpkgs.lib;

    # Every host is `hosts/<name>/default.nix` plus the shared platform/overlay
    # module; `host` is threaded through to modules/core and home-manager.
    mkHost = host: nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform.system = system; nixpkgs.overlays = overlays; }
        (import (./hosts + "/${host}"))
      ];
      specialArgs = { inherit host self inputs username; };
    };
  in
  {
    nixosConfigurations = {
      desktop = mkHost "desktop";
      laptop = mkHost "laptop";
      work-laptop = mkHost "work-laptop";
    };
  };
}
