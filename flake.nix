{
  description = "Brennan's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    # Last nixpkgs where zotero builds (2026-10-06 unstable fails patching
    # ActorManagerParent.sys.mjs). Drop once upstream zotero builds again.
    nixpkgs-zotero.url = "github:NixOS/nixpkgs/20b1ddd1aa5ace70c9468305030aa4f9ef79671b";

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
        mcuxpressoide = final.callPackage (self + "/pkgs/mcuxpressoide.nix") { };
        mcuxpresso-installer-pkexec = final.callPackage (self + "/pkgs/mcuxpresso-installer-pkexec.nix") { };

        # Only VS Code sees the MCUXpresso pkexec shim (it passes anything
        # that isn't the MCUXpresso Installer through to the real pkexec).
        vscode = final.symlinkJoin {
          inherit (prev.vscode) name meta passthru;
          paths = [ prev.vscode ];
          nativeBuildInputs = [ final.makeWrapper ];
          postBuild = ''
            rm $out/bin/code
            makeWrapper ${prev.vscode}/bin/code $out/bin/code \
              --prefix PATH : ${final.mcuxpresso-installer-pkexec}/bin
          '';
        };
        zotero = inputs.nixpkgs-zotero.legacyPackages.${system}.zotero;

        # On the Intel+NVIDIA PRIME work-laptop, Bitwarden's Electron GPU
        # process wakes the dGPU and hands Hyprland (compositing on the iGPU)
        # dmabufs it can't import (EGL_BAD_MATCH), which hangs/aborts the
        # compositor. A password manager doesn't need GPU acceleration.
        # Wrapped via symlinkJoin so bitwarden itself isn't rebuilt.
        bitwarden-desktop = final.symlinkJoin {
          inherit (prev.bitwarden-desktop) name meta;
          paths = [ prev.bitwarden-desktop ];
          nativeBuildInputs = [ final.makeWrapper ];
          postBuild = ''
            rm $out/bin/bitwarden
            makeWrapper ${prev.bitwarden-desktop}/bin/bitwarden $out/bin/bitwarden \
              --add-flags "--disable-gpu"
          '';
        };
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
