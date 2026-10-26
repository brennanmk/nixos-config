{ pkgs, config, lib, ... }:

{
    services.xserver.enable = true;
    services.xserver.videoDrivers = ["nvidia"];

    # Arrow Lake-H iGPU (Xe-LPG+). i915 still claims Arrow Lake by default on
    # mainline; do not force-probe `xe` unless something is actually broken.
    boot.kernelModules = [ "i915" ];
    boot.kernelParams = [
        "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
        "nvidia_drm.modeset=1"
        "nvidia_drm.fbdev=1"
    ];

    hardware = {
        nvidia = {
            # RTX PRO 2000 is Blackwell (GB20x): needs a >=570 branch driver.
            package = config.boot.kernelPackages.nvidiaPackages.production;
            modesetting.enable = lib.mkDefault true;

            # Suspend/resume VRAM save-restore. `powerManagement.finegrained`
            # (runtime-D3: dGPU powers off when nothing is offloaded to it) is
            # the bigger battery win, but some OEM firmware resumes badly from
            # it — enable after suspend/resume is verified on this chassis.
            powerManagement.enable = lib.mkDefault true;

            # Blackwell has no proprietary kernel-module path — the open GSP
            # modules are the only supported option here.
            open = true;

            prime = {
                offload.enable = true;
                offload.enableOffloadCmd = true;
                # `./install` rewrites these from `lspci` on first run. 00:02.0
                # is the fixed Intel iGPU slot; the dGPU sits behind the first
                # PCIe root port on Arrow Lake-H designs.
                intelBusId = lib.mkDefault "PCI:0:2:0";
                nvidiaBusId = lib.mkDefault "PCI:1:0:0";
            };
        };

        graphics = {
            enable = true;
            enable32Bit = true;
            # iGPU video accel (VA-API `iHD` + oneVPL). Unlike hosts/laptop this
            # deliberately does NOT override `graphics.package`: replacing mesa
            # with nvidia_x11 strips the Intel DRI drivers the iGPU renders on.
            extraPackages = with pkgs; [
                intel-media-driver
                vpl-gpu-rt
                libvdpau-va-gl
            ];
        };
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
