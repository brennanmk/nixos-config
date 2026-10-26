{ pkgs, ... }:
{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openconnect ];

      # Tufts VPN (Cisco AnyConnect). On-demand only: autoconnect = false,
      # so it never dials unless brought up explicitly.
      # NOTE: activating this profile requires the graphical auth dialog
      # (nm-applet / nm-connection-editor). From a terminal use `tufts-vpn`.
      ensureProfiles.profiles."tufts-vpn" = {
        connection = {
          id = "Tufts VPN";
          uuid = "4f1c9b10-7d2e-4a63-9c58-8b1f2e0a3d77";
          type = "vpn";
          autoconnect = false;
        };
        vpn = {
          service-type = "org.freedesktop.NetworkManager.openconnect";
          protocol = "anyconnect";
          gateway = "vpn.tufts.edu/duo";
          authtype = "password";
          enable_csd_trojan = "no";
          autoconnect = "no";
          # 2 = "not saved, ask every time" -> no creds/cookies on disk
          gwcert-flags = "2";
          cookie-flags = "2";
          gateway-flags = "2";
          lasthost-flags = "2";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
    firewall.enable = false;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    openconnect
    pass

    # On-demand Tufts VPN, terminal-driven (no NM auth dialog needed).
    #   tufts-vpn login       store UTLN + AD password (password goes in `pass`)
    #   tufts-vpn up [utln]   tufts-vpn down   tufts-vpn status
    #
    # Credentials: UTLN in ~/.config/tufts-vpn/utln (not secret), AD password in
    # `pass` under tufts/vpn (gpg-encrypted; gpg-agent caches the unlock).
    # The Duo factor is a second factor and is never stored -- `up` asks for it
    # ("push", "phone", or a 6-digit passcode) and defaults to "push".
    (writeShellScriptBin "tufts-vpn" ''
      set -euo pipefail
      PATH=${pkgs.openconnect}/bin:${pkgs.pass}/bin:${pkgs.gnupg}/bin:${pkgs.gnugrep}/bin:${pkgs.iproute2}/bin:${pkgs.coreutils}/bin:${pkgs.procps}/bin:$PATH
      PIDFILE=/run/tufts-vpn.pid
      UTLNFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/tufts-vpn/utln"
      PASSENTRY="''${TUFTS_PASS_ENTRY:-tufts/vpn}"

      read_utln() {
        if [ -s "$UTLNFILE" ]; then head -n1 "$UTLNFILE"; fi
      }

      case "''${1:-up}" in
        login)
          # pass insert would otherwise create a half-built store then fail.
          STORE="''${PASSWORD_STORE_DIR:-$HOME/.password-store}"
          if [ ! -s "$STORE/.gpg-id" ]; then
            echo "pass is not initialised. One-time setup:" >&2
            if ! gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec:'; then
              echo "  gpg --quick-generate-key \"<your-email>\" default default never" >&2
            fi
            echo "  pass init <your-gpg-key-id-or-email>" >&2
            exit 1
          fi
          user="''${2:-$(read_utln)}"
          if [ -z "$user" ]; then
            read -rp "Tufts username (UTLN): " user
          fi
          mkdir -p "$(dirname "$UTLNFILE")"
          printf '%s\n' "$user" > "$UTLNFILE"
          echo "UTLN saved to $UTLNFILE"
          pass insert -f "$PASSENTRY"
          echo "password saved to pass:$PASSENTRY"
          ;;
        up)
          user="''${2:-''${TUFTS_UTLN:-$(read_utln)}}"
          if [ -z "$user" ]; then
            read -rp "Tufts username (UTLN): " user
          fi
          if [ -e "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "already connected (pid $(cat "$PIDFILE"))" >&2; exit 0
          fi
          if ! passwd="$(pass show "$PASSENTRY" 2>/dev/null | head -n1)" || [ -z "$passwd" ]; then
            echo "no password in pass:$PASSENTRY -- run 'tufts-vpn login' first" >&2
            exit 1
          fi
          read -rp "Duo factor [push]: " duo || true
          duo="''${duo:-push}"
          # Prime sudo on the tty first: with stdin piped it cannot prompt, and
          # it would otherwise swallow the password line meant for openconnect.
          sudo -v
          printf '%s\n%s\n' "$passwd" "$duo" | sudo openconnect \
            --protocol=anyconnect \
            --user="$user" \
            --passwd-on-stdin \
            --background \
            --pid-file="$PIDFILE" \
            https://vpn.tufts.edu/duo
          ;;
        down)
          if [ -e "$PIDFILE" ]; then
            sudo kill "$(cat "$PIDFILE")" && echo "disconnected"
          else
            echo "not connected" >&2; exit 1
          fi
          ;;
        status)
          if [ -e "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
            echo "connected (pid $(cat "$PIDFILE"))"
            ip -brief addr show tun0 2>/dev/null || true
          else
            echo "not connected"
          fi
          ;;
        *)
          echo "usage: tufts-vpn [login [utln]|up [utln]|down|status]" >&2; exit 1 ;;
      esac
    '')
  ];
}
