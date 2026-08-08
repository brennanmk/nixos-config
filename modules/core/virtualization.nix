{ config, pkgs, lib, username, ... }:
{
  # Enable Docker, Podman, and the modern NVIDIA toolkit
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  # Add user to libvirtd group (and docker/podman if you want rootless access)
  users.users.${username}.extraGroups = [ "libvirtd" "docker" ];

  # Install necessary packages for VM management
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
