{ pkgs, config, lib, ... }:

{
    boot.kernelModules = [ "amdgpu" ];

    services.xserver.videoDrivers = ["nvidia"];
    services.power-profiles-daemon.enable = lib.mkDefault true;

    hardware = {
        opengl = {
            enable = true;
            driSupport = true;
        };

        nvidia = {
            modesetting.enable = lib.mkDefault true;
            powerManagement.enable = lib.mkDefault true;
            open = lib.mkDefault false;

            prime = {
                amdgpuBusId = lib.mkDefault "PCI:34:0:0";
                nvidiaBusId = "PCI:1:0:0";
            };
        };
    };

}
