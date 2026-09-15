{ inputs, pkgs, ... }:
{
  # Add npm global bin to PATH declaratively
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Dracula theme for nmtui (newt color slots map to terminal palette)
  home.sessionVariables.NEWT_COLORS = ''
    root=white,black
    border=blue,black
    window=white,black
    shadow=darkgrey,black
    title=blue,black
    button=black,cyan
    actbutton=black,blue
    checkbox=white,black
    actcheckbox=black,blue
    entry=white,black
    label=cyan,black
    listbox=white,black
    actlistbox=black,blue
    textbox=white,black
    acttextbox=black,cyan
    helpline=darkgrey,black
    roottext=blue,black
    emptyscale=,black
    fullscale=,blue
    disentry=darkgrey,black
    compactbutton=black,cyan
    actsellistbox=black,blue
    sellistbox=blue,black
  '';

  home.packages = (
    with pkgs;
    [
      bitwise # cli tool for bit / hex manipulation
      file # Show file information
      hexdump
      jq # command-line JSON processor
      jdk17
      nitch # systhem fetch util
      nix-prefetch-github
      ripgrep # grep replacement
      # C / C++
      gcc
      gnumake
      cmake
      libtool
      clang-tools # provides clangd LSP server
      lazysql

      # Erlang / Elixir
      beamPackages.erlang
      beamPackages.elixir
      elixir-ls # provides elixir-ls LSP server
      erlang-language-platform # provides elp LSP server for erlang
      nixfmt
      claude-code
      antigravity-cli # replaces gemini-cli, which is being removed from nixpkgs

      # general appliactions
      firefox
      slack
      emacs30-pgtk
      emacs-lsp-booster

      spotify
      feh
      evince
      zotero
      libreoffice
      htop
      (lib.hiPrio cudatoolkit)
      polybar
      htop
      obs-studio
      bitwarden-desktop
      sqlite
      prusa-slicer
      discord
      vesktop
      webcord

      nodejs

      rustup

      #image writing
      caligula

      # LLM magic
      claude-agent-acp
      opencode

      unityhub

      #system utils
      bluetuith
      pulsemixer
      pavucontrol
      hyprmon
      nemo
      piper # GUI for ratbagd (gaming mouse config)

      inotify-tools
      nvidia-container-toolkit
      texliveFull

      davfs2
      wofi
      picocom
      rclone
      wl-mirror

      #xfce
      blueman

      (pkgs.python3.withPackages (ps: with ps; [
        black
        setuptools
        packaging
      ]))
      pkgs.ruff
      basedpyright # Python LSP: type-checking, completion, navigation
      nixd # Nix LSP server
      dasel # used by Emacs `pet` to parse pyproject.toml / detect venvs

      (aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
          en-science
        ]
      ))

      jdt-language-server
      marksman
      nil
      docker-compose
      yaml-language-server
      lemminx
      dockerfile-language-server
      docker-compose-language-service
      zlib
      psmisc
      cmatrix
      gparted # partition manager
      ffmpeg
      imv # image viewer
      libnotify
      ghostscript # PostScript / PDF interpreter
      man-pages # extra man pages
      mpv # video player
      ncdu # disk space
      openssl
      pamixer # pulseaudio command line mixer
      playerctl # controller for media players
      unzip
      wget
    ]
  );
}
