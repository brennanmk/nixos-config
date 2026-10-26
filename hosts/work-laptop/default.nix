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

  # No GUI Thunderbolt applet on Hyprland to auto-approve new docks, so
  # without boltd the TB5 dock's PCIe tunnel (its onboard Ethernet, etc.)
  # stays stuck at authorized=0 forever even though USB/DP tunnels through
  # it work unauthorized. Enroll new devices once with
  # `boltctl enroll --policy auto <uuid>` (see `boltctl list`) so they're
  # trusted automatically on every future connect.
  services.hardware.bolt.enable = true;

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

  # saleae-logic-2 (installed via modules/home/work-laptop) ships its own
  # 99-SaleaeLogic.rules (grants the analyzer's USB VID/PIDs MODE=0666)
  # inside $out/etc/udev/rules.d; udev rules are a system-level (not
  # home-manager) concept, so this registration has to live here rather
  # than alongside the package itself. Just needs to be registered so
  # NixOS actually installs it, rather than manually copying the rules
  # file into /etc/udev/rules.d.
  #
  # MCUXpresso IDE's unpacked tree carries NXP's LinkServer/MCU-Link/
  # LPCScrypt and P&E Micro probe rules (all plain MODE="0666").
  services.udev.packages = [
    pkgs.saleae-logic-2
    pkgs.segger-jlink
    pkgs.mcuxpressoide.unwrapped
  ];

  # The built-in I219-LM (e1000e, enp0s31f6) flaps its link every 1-3 min
  # and DHCP times out when it negotiates Energy Efficient Ethernet with some
  # switches; USB adapters on the same cable are fine. Turn EEE off on it.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", ENV{ID_NET_DRIVER}=="e1000e", RUN+="${pkgs.ethtool}/bin/ethtool --set-eee $name eee off"

    # TI debug probes for Code Composer Studio (run via Docker, see ~/ccs), as CCS's
    # install_scripts/71-ti-permissions.rules + 61-msp430uif.rules would set:
    # XDS100 (FTDI a6d0/a6d1), XDS110/XDS200/ICDI (0451:bef*, 1cbe:00fd),
    # MSP-FET/eZ-FET (2047:*).
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="a6d[01]", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="bef?", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1cbe", ATTRS{idProduct}=="00fd", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2047", MODE="0666"
  '';

  # segger-jlink (installed via modules/home/work-laptop) refuses to evaluate
  # until SEGGER's license is explicitly accepted. Set at the system level
  # since home-manager uses the global pkgs (useGlobalPkgs).
  nixpkgs.config.segger-jlink.acceptLicense = true;
  # Every J-Link executable ships linked against a bundled, EOL Qt 4 that
  # nixpkgs marks insecure; the package's `headless` variant drops *all*
  # binaries (library only), so there is no CLI-only alternative.
  nixpkgs.config.permittedInsecurePackages = [ "segger-jlink-qt4-970" ];

  # VS Code's MCUXpresso extension only auto-detects J-Link by globbing
  # /opt/SEGGER/JLink*/JLinkGDBServerCLExe (or a manual mcuxpresso.segger.path
  # setting), and only counts it as installed if it can read a version out of
  # <that dir>/Doc/ReleaseNotes/ReleaseNotes*.html. nixpkgs moves Doc out to
  # share/docs, so rebuild the upstream layout as a symlink tree.
  systemd.tmpfiles.rules =
    let
      jlinkOpt = pkgs.runCommand "segger-jlink-opt" { } ''
        mkdir $out
        ln -s ${pkgs.segger-jlink}/opt/SEGGER/JLink/* $out/
        ln -s ${pkgs.segger-jlink}/share/docs $out/Doc
      '';
    in
    [
      "L+ /opt/SEGGER/JLink - - - - ${jlinkOpt}"
      # MCUXpresso Installer's sudo-prompt only looks for pkexec here.
      "L+ /usr/bin/pkexec - - - - ${pkgs.mcuxpresso-installer-pkexec}/bin/pkexec"
      # The pkexec shim installs the Installer here instead of
      # ~/MCUXpressoInstaller; this is the VS Code extension's other probe path.
      "L+ /usr/local/MCUXpressoInstaller - - - - /home/${username}/.local/share/MCUXpressoInstaller"
    ];

  # MCUXpresso Installer (an Electron app the VS Code extension unpacks into
  # ~/.local/share/MCUXpressoInstaller) and the prebuilt toolchains it
  # downloads into ~/.mcuxpressotools (Arm GCC/GDB, CMake, ninja,
  # python-build-standalone) are generic-Linux binaries, so they run through nix-ld (enabled in
  # modules/core with an empty list; this merges into it).
  programs.nix-ld.libraries = with pkgs; [
    # Electron
    glib
    nspr
    nss
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    cairo
    gtk3
    pango
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxkbcommon
    libgbm
    expat
    alsa-lib
    # Arm GNU toolchain gdb / vendor probe tools (Arm's 14.x gdb wants
    # ncurses 6, the IDE's bundled older gdb ncurses 5; gdb-py's
    # libpython3.8 isn't in nixpkgs anymore, so only plain gdb works)
    ncurses
    ncurses5
    libxcrypt-legacy
    libusb1
  ];

  # Pin git.whoi.edu to its internal address rather than whatever DNS hands
  # back.
  networking.hosts."10.127.48.203" = [ "git.whoi.edu" ];

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
    # unreachable with the lid shut. Masking fprintd.service alone doesn't
    # stop it: this system's dbus-broker activates fprintd straight off the
    # `Exec=` line in net.reactivated.Fprint.service, bypassing systemd (and
    # its mask) entirely, so pam_fprintd on sudo/hyprlock still gets a live
    # daemon and hangs on a scan timeout. Deauthorizing the USB device itself
    # (synaptics reader, 06cb:00f9) is what actually stops it — fprintd still
    # starts but finds no hardware and fails immediately. Keep the mask/stop
    # too, in case anything ever starts it the systemd-tracked way.
    acpid = {
      enable = true;
      lidEventCommands = ''
        state=$(${pkgs.gawk}/bin/awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null)

        usbdev=""
        for d in /sys/bus/usb/devices/*/; do
          if [ "$(cat "$d/idVendor" 2>/dev/null)" = "06cb" ] && [ "$(cat "$d/idProduct" 2>/dev/null)" = "00f9" ]; then
            usbdev=$d
            break
          fi
        done

        if [ "$state" = "closed" ]; then
          action=off
          [ -n "$usbdev" ] && echo 0 > "$usbdev/authorized"
          ${pkgs.systemd}/bin/systemctl mask --runtime fprintd.service
          ${pkgs.systemd}/bin/systemctl stop fprintd.service
        else
          action=on
          ${pkgs.systemd}/bin/systemctl unmask --runtime fprintd.service
          [ -n "$usbdev" ] && echo 1 > "$usbdev/authorized"
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
