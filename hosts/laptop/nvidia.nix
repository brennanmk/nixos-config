{ pkgs, config, libs, ... }:

{
    boot.kernelModules = [ "amdgpu" ];

    services.xserver.videoDrivers = ["nvidia"];

    hardware = {
        opengl = {
            enable = true;
            driSupport = true;
            driSuupport32Bit = true;
        };

        amdgpu.loadInInitrd = lib.mkDefault false;

        nvidia = {
            modesetting.enable = lib.mkDefault true;
            powerManagement.enable = lib.mkDefault true;

            prime = {
                amdgpuBusId = lib.mkDefault "PCI:6:0:0";
                nvidiaBusId = "PCI:1:0:0";
            };
        };
    };

}
