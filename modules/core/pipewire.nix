{ pkgs, ... }: 
{
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    # lowLatency.enable = true;
    #
    wireplumber = {
      enable = true;
      configPackages = [];
    };
  };
  environment.systemPackages = with pkgs; [
    pulseaudioFull
  ];
}
