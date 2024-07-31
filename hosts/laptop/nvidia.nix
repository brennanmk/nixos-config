{ pkgs, config, lib, ... }:

{
    boot.kernelModules = [ "amdgpu" ];
    hardware = {
        nvidia = {
            package = config.boot.kernelPackages.nvidiaPackages.beta;
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
