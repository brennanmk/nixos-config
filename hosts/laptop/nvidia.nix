{ pkgs, config, lib, ... }:

let
  driverPkg = config.boot.kernelPackages.nvidiaPackages.beta;
in
{
    services.xserver.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    boot.kernelModules = [ "amdgpu" ];
    boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
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

        graphics = {
               enable = true;
               enable32Bit = true;
               package = driverPkg;
        };
    };

}
