{ config, pkgs, lib, username, ... }:
{
  # Enable docker
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.docker.package = pkgs.docker;

  # Fix nvidia-container-runtime to find runc in nix store
  environment.etc."nvidia-container-runtime/config.toml".text = lib.mkForce ''
    disable-require = true
    supported-driver-capabilities = "compat32,compute,display,graphics,ngx,utility,video"

    [nvidia-container-cli]
    environment = []
    ldconfig = "@${pkgs.glibc.bin}/bin/ldconfig"
    load-kmods = true
    no-cgroups = false
    path = "${pkgs.libnvidia-container}/bin/nvidia-container-cli"

    [nvidia-container-runtime]
    mode = "auto"
    runtimes = ["${pkgs.runc}/bin/runc"]

    [nvidia-container-runtime-hook]
    path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime-hook"
    skip-mode-detection = false

    [nvidia-ctk]
    path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-ctk"
  '';
  # Add user to libvirtd group
  users.users.${username}.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
