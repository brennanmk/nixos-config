{ hostname, config, lib, pkgs, host, ...}:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "direnv"];
    };
    initContent = ''
      DISABLE_MAGIC_FUNCTIONS=true
      export "MICRO_TRUECOLOR=1"
      TERM=xterm-256color
      bindkey '^ ' autosuggest-accept
    '';

    shellAliases = {
      # Nixos
      mirror = "xrandr --output HDMI-0 --auto --scale-from 2560x1600 --same-as DP-4";
      nix-shell = "nix-shell --run zsh";
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#${host}";
      nix-switchu = "sudo nixos-rebuild switch --upgrade --flake ~/nixos-config#${host}";
      nix-flake-update = "sudo nix flake update ~/nixos-config#";
      nix-clean = "sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo rm /nix/var/nix/gcroots/auto/* && nix-collect-garbage && nix-collect-garbage -d";
      sshk = "kitty +kitten ssh";
      doom = "~/.config/emacs/bin/doom";
      phone = "f() { curl --silent --output nul -d $1 https://ntfy.bmillerklugman.me/phone };f";
    };

  };

  programs.zsh.plugins = [
  {
    name = "powerlevel10k";
    src = pkgs.zsh-powerlevel10k;
    file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  }
  {
    name = "powerlevel10k-config";
    src = lib.cleanSource ./p10k-config;
    file = "p10k.zsh";
  }
];
}
