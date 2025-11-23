{ config, pkgs, username, ... }:
{
  # Enable docker
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.docker.package = pkgs.docker;
  # Add user to libvirtd group
  users.users.${username}.extraGroups = [ "libvirtd" ];

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice spice-gtk
    spice-protocol
    win-virtio
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
