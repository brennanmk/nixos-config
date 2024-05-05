{ pkgs, ... }: 
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    nameservers = [ "8.8.8.8" ];
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
