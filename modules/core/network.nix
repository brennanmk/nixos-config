{ pkgs, ... }: 
{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openconnect ];
    };
    firewall.enable = false;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    openconnect
  ];
}
