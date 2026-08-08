{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
  ];

  # Many DX12/Proton titles (esync/fsync heavy) crash or stutter with the
  # low stock value. Matches the Steam Deck default.
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
}
