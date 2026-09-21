{ pkgs, username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
  ];

  hardware.enableAllFirmware = true;
  hardware.nvidia-container-toolkit.enable = true;
  services.blueman.enable = true;

  # bitwarden-desktop is home-manager-installed (per-user profile), so its
  # bundled polkit action for biometric unlock never reaches system polkitd,
  # which only scans /run/current-system/sw. Expose just that one file so
  # "Unlock with system authentication" can trigger fprintd via pam_fprintd
  # (already stacked into security.pam.services.polkit-1 by default).
  environment.etc."polkit-1/actions/com.bitwarden.Bitwarden.policy".source =
    "${pkgs.bitwarden-desktop}/share/polkit-1/actions/com.bitwarden.Bitwarden.policy";

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    powertop
    libinput
    libinput-gestures
    intel-gpu-tools   # intel_gpu_top, replaces the amdgpu tooling

    # Integrated smartcard reader (usb 2ce3:9563, USB class 0x0b == CCID) for
    # CAC/PIV auth in the browser. opensc-pkcs11.so lands at the stable path
    # /run/current-system/sw/lib/opensc-pkcs11.so since opensc is here in
    # systemPackages — register that path once in Firefox under
    # about:preferences#privacy -> Security Devices -> Load.
    opensc
    pcsc-tools   # pcsc_scan, to verify the reader/card are visible to pcscd
  ];

  services = {
    # Synaptics fingerprint reader (usb 06cb:00f9). fprintd.enable also flips
    # security.pam.fprintAuth's default to true, which auto-enables fingerprint
    # unlock for hyprlock via the pam.services.hyprlock entry in modules/core.
    fprintd.enable = true;

    # Smartcard reader is generic USB CCID class, so the default `ccid`
    # plugin handles it with no vendor-specific config.
    pcscd.enable = true;

    # HandleLidSwitchDocked (unchanged, defaults to "ignore") means logind
    # does nothing to the display when docked and the lid closes, so the
    # internal panel just stays lit behind the closed lid. Reach into the
    # user's Hyprland session directly to DPMS-off/on just the internal
    # panel on physical lid close/open; harmless when undocked too, since
    # HandleLidSwitch's own suspend blanks everything right after anyway.
    #
    # The fingerprint reader lives on the palm rest, so it's physically
    # unreachable with the lid shut. Stop (and mask, so D-Bus activation
    # can't silently bring it back) fprintd while closed, and restore it
    # on open.
    acpid = {
      enable = true;
      lidEventCommands = ''
        state=$(${pkgs.gawk}/bin/awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null)

        if [ "$state" = "closed" ]; then
          action=off
          ${pkgs.systemd}/bin/systemctl mask --runtime fprintd.service
          ${pkgs.systemd}/bin/systemctl stop fprintd.service
        else
          action=on
          ${pkgs.systemd}/bin/systemctl unmask --runtime fprintd.service
        fi

        runtimeDir=/run/user/$(${pkgs.coreutils}/bin/id -u ${username})
        sig=$(${pkgs.coreutils}/bin/ls "$runtimeDir/hypr" 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)
        [ -z "$sig" ] && exit 0
        # Hyprland >=0.56's hyprctl builds "hl.dispatch(<dispatcher> <args>)" from
        # raw argv with no quoting, so a dispatch call now has to be handed over
        # pre-formed as a single Lua expression rather than legacy "dpms off eDP-1".
        ${pkgs.util-linux}/bin/runuser -u ${username} -- \
          env XDG_RUNTIME_DIR="$runtimeDir" HYPRLAND_INSTANCE_SIGNATURE="$sig" \
          ${pkgs.hyprland}/bin/hyprctl dispatch "hl.dsp.dpms({state=\"$action\", monitor=\"eDP-1\"})"
      '';
    };

    # Intel DPTF thermal/power policy — the reason this host does not need
    # cpupower/acpi_call the way hosts/laptop does.
    thermald.enable = true;

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    # Core Ultra 9 runs intel_pstate, which only exposes powersave/performance;
    # the governor split plus EPP hints is what actually controls the P/E-core
    # boost behaviour here.
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          energy_performance_preference = "balance_power";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          energy_performance_preference = "performance";
          turbo = "auto";
        };
      };
    };
  };

  system.nixos.tags = [ "default" ];
}
