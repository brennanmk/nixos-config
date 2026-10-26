{
  lib,
  stdenvNoCC,
  requireFile,
  dpkg,
  buildFHSEnv,
  makeDesktopItem,
  runCommand,
}:

# NXP MCUXpresso IDE (Eclipse/CDT based). Shipped only as a login-gated
# makeself .deb.bin whose install.sh drives dpkg/apt/PPAs as root, so instead:
# unpack the IDE + LinkServer/MCU-Link/LPCScrypt debs into the store with the
# same /usr/local layout their postinst scripts would create, then run the IDE
# inside an FHS env that mounts that layout at /usr/local. The bundled J-Link
# .deb is skipped in favor of pkgs.segger-jlink (exposed at /opt/SEGGER/JLink
# by hosts/work-laptop, which is the IDE's default J-Link path).

let
  version = "11.10.0_3148";
  linkserverVersion = "1.6.133";

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "mcuxpressoide-unwrapped";
    inherit version;

    src = requireFile {
      name = "mcuxpressoide-${version}.x86_64.deb.bin";
      hash = "sha256-F05u0FIhSNbqs0zeebMulWHtmeWZGgt1NKFxuqfx0sk=";
      message = ''
        MCUXpresso IDE has to be downloaded manually from nxp.com (login
        required), then added to the store with:

          nix-store --add-fixed sha256 mcuxpressoide-${version}.x86_64.deb.bin
      '';
    };

    nativeBuildInputs = [ dpkg ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    # 2.6G of vendor binaries, many of them other-arch/target images; leave
    # them exactly as shipped (they're run inside the FHS env, not patched).
    dontStrip = true;
    dontPatchELF = true;
    dontPatchShebangs = true;

    installPhase = ''
      runHook preInstall

      sh $src --nox11 --noexec --target ide-installer > /dev/null
      sh ide-installer/LinkServer_${linkserverVersion}.x86_64.deb.bin \
        --nox11 --noexec --target linkserver-installer > /dev/null

      mkdir root
      for deb in ide-installer/mcuxpressoide-${version}.x86_64.deb linkserver-installer/*.deb; do
        dpkg-deb -x "$deb" root
      done

      mkdir -p $out
      mv root/usr/local $out/local

      # udev rules ship in a mix of /lib and /etc; gather them for
      # services.udev.packages.
      mkdir -p $out/lib/udev/rules.d
      find root -path '*udev/rules.d/*.rules' -type f -exec cp {} $out/lib/udev/rules.d/ \;
      cp root/usr/lib/libp64-0.1.so.4 $out/lib/

      # Recreate what the debs' postinst scripts symlink at install time.
      ide=$out/local/mcuxpressoide-${version}/ide
      ln -s plugins/com.nxp.mcuxpresso.tools.bin.linux_*/binaries $ide/binaries
      ln -s plugins/com.nxp.mcuxpresso.tools.wizards_*/Examples $ide/Examples
      ln -s plugins/com.nxp.mcuxpresso.tools.linux_*/tools $ide/tools
      ln -s plugins/com.nxp.mcuxpresso.tools.wizards_*/Wizards $ide/Wizards
      ln -s /usr/local/LinkServer_${linkserverVersion} $ide/LinkServer
      for d in $out/local/*/; do
        d=$(basename "$d")
        case $d in
          mcuxpressoide-*) ln -s $d $out/local/mcuxpressoide ;;
          LinkServer_*) ln -s $d $out/local/LinkServer ;;
          MCU-LINK_installer_*) ln -s $d $out/local/MCU-LINK_installer ;;
          lpcscrypt-*) ln -s $d $out/local/lpcscrypt ;;
        esac
      done
      ln -s /usr/local/MCU-LINK_installer $out/local/LinkServer_${linkserverVersion}/MCU-LINK_installer
      ln -s /usr/local/lpcscrypt $out/local/LinkServer_${linkserverVersion}/lpcscrypt

      runHook postInstall
    '';

    meta = {
      description = "NXP MCUXpresso IDE (unpacked vendor tree)";
      license = lib.licenses.unfree;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
    };
  };

  # P&E Micro's libp64 is the one library the IDE deb drops in /usr/lib.
  vendorLibs = runCommand "mcuxpressoide-libs" { } ''
    mkdir -p $out/lib
    ln -s ${unwrapped}/lib/libp64-0.1.so.4 $out/lib/
  '';

  desktopItem = makeDesktopItem {
    name = "mcuxpressoide";
    desktopName = "MCUXpresso IDE";
    comment = "NXP MCUXpresso IDE ${version}";
    exec = "mcuxpressoide";
    icon = "${unwrapped}/local/mcuxpressoide-${version}/ide/icon.xpm";
    categories = [ "Development" ];
  };
in
buildFHSEnv {
  pname = "mcuxpressoide";
  inherit version;

  targetPkgs =
    pkgs: with pkgs; [
      # Eclipse/SWT (its bundled JRE handles the rest of the JVM side)
      gtk3
      glib
      cairo
      pango
      gdk-pixbuf
      atk
      webkitgtk_4_1
      libsecret
      fontconfig
      freetype
      alsa-lib
      zlib
      libx11
      libxext
      libxi
      libxrender
      libxtst
      libxxf86vm

      # bundled Arm GNU toolchain / gdb and vendor debug tools
      ncurses5
      libxcrypt-legacy
      readline
      libffi
      tcl-8_6
      libusb1
      libusb-compat-0_1
      udev
      dfu-util
      gnumake
      which
      python3
    ]
    ++ [ vendorLibs ];

  # The rootfs is read-only at runtime (bwrap can't create a /usr/local
  # mountpoint in it), so link the vendor tree in at build time instead.
  extraBuildCommands = ''
    ln -s ${unwrapped}/local $out/usr/local
  '';

  runScript = "/usr/local/mcuxpressoide-${version}/ide/mcuxpressoide";

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/
  '';

  passthru = { inherit unwrapped; };

  meta = unwrapped.meta // {
    description = "NXP MCUXpresso IDE";
    mainProgram = "mcuxpressoide";
  };
}
