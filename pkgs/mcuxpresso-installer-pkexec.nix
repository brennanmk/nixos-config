{
  writeShellApplication,
  bash,
  coreutils,
  dpkg,
  findutils,
  gawk,
  gnutar,
  gzip,
}:

# Stand-in pkexec for NXP's MCUXpresso tooling, which assumes Ubuntu:
#
# - VS Code's MCUXpresso extension installs the "MCUXpresso Installer" by
#   running `pkexec MCUXpressoInstaller.deb.bin`. That makeself bundle's
#   install.sh only needs root to chown and set the setuid bit on Electron's
#   chrome-sandbox; the real work is `dpkg -x` into ~/MCUXpressoInstaller,
#   which the extension then looks for. Done here unprivileged, and into
#   ~/.local/share/MCUXpressoInstaller instead to keep it out of ~; the
#   extension finds it through its other probe path,
#   /usr/local/MCUXpressoInstaller, which hosts/work-laptop links there. (Reached via
#   VS Code's PATH, see the vscode overlay in flake.nix.)
#
# - The Installer itself elevates through sudo-prompt, which only probes the
#   absolute paths /usr/bin/kdesudo and /usr/bin/pkexec (hosts/work-laptop
#   links this there) and runs `pkexec --disable-internal-agent /bin/bash -c
#   "echo SUDOPROMPT; <cmd>"`. The only elevated commands are apt/PPA
#   installs of runtime libs (ncurses, libpython3.8) that nix-ld provides
#   instead, so report those as done rather than failing the component.
#
# Every other pkexec call is passed through to the real setuid wrapper.
writeShellApplication {
  name = "pkexec";
  # makeself's extractor shells out to tail/awk/tar/gzip/df itself.
  runtimeInputs = [
    bash
    coreutils
    dpkg
    findutils
    gawk
    gnutar
    gzip
  ];
  text = ''
    if [ "$#" -eq 1 ] && [[ "$(basename "$1")" == MCUXpressoInstaller*.deb.bin ]]; then
      tmp=$(mktemp -d)
      trap 'rm -rf "$tmp"' EXIT

      sh "$1" --quiet --nox11 --noexec --target "$tmp/bundle"

      # Mirror install.sh: wipe the previous install but keep the user's
      # config.ini and download cache.
      dir=$HOME/.local/share/MCUXpressoInstaller
      if [ -d "$dir" ]; then
        find "$dir" -mindepth 1 -maxdepth 1 ! -name config ! -name .cache -exec rm -rf {} +
      fi
      [ -f "$dir/config/config.ini" ] && mv -f "$dir/config/config.ini" "$tmp/config.ini"
      dpkg-deb -x "$tmp"/bundle/MCUXpressoInstaller_*.deb "$tmp/deb"
      mkdir -p "$dir"
      cp -a "$tmp"/deb/MCUXpressoInstaller/. "$dir"/
      [ -f "$tmp/config.ini" ] && mv -f "$tmp/config.ini" "$dir/config/config.ini"

      # Can't be setuid root from here; without it Electron falls back to the
      # user-namespace sandbox, which NixOS allows.
      rm -f "$dir/chrome-sandbox"

      echo "INFO: Installation directory: $dir"
      exit 0
    fi

    if [ "$#" -eq 4 ] && [ "$1" = --disable-internal-agent ] && [ "$2" = /bin/bash ] && [ "$3" = -c ]; then
      cmd=''${4#echo SUDOPROMPT; }
      cmd=''${cmd//\"/}
      if [[ "$cmd" =~ ^(apt|apt-get|add-apt-repository)[[:space:]] || "$cmd" == *install_libncurses_ubuntu.sh* ]]; then
        echo SUDOPROMPT
        echo "pkexec shim: skipped '$cmd' (dependency comes from nix-ld on NixOS)" >&2
        exit 0
      fi
    fi

    if [ -x /run/wrappers/bin/pkexec ]; then
      exec /run/wrappers/bin/pkexec "$@"
    fi
    echo "pkexec: no setuid pkexec wrapper (security.polkit is not enabled)" >&2
    exit 127
  '';
}
