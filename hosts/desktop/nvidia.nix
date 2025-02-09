{ pkgs, config, libs, ... }:

{  

  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [nvidia-vaapi-driver intel-media-driver];
    };

    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
    nvidia-container-toolkit = {
      enable = true;
    };
  };
}
