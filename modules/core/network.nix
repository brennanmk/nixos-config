{ pkgs, ... }: 
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # firewall.enable = false;
    nameservers = [ "8.8.8.8" ];
    extraHosts =
      ''
      10.0.30.175 dashboard
      10.0.30.204 grisp-001350
      '';
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
