{ inputs, pkgs, ... }:
{
  # Add npm global bin to PATH declaratively
  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # nmtui theme (newt color slots map to terminal palette; names are S-Lang's:
  # gray = color8, lightgray = color7). Focus is always black-on-yellow so it
  # stands out from Catppuccin's similar blue/cyan; entries get a gray bar.
  home.sessionVariables.NEWT_COLORS = ''
    root=white,black
    border=blue,black
    window=white,black
    shadow=gray,black
    title=blue,black
    button=white,gray
    actbutton=black,yellow
    compactbutton=white,black
    checkbox=white,black
    actcheckbox=black,yellow
    entry=white,gray
    disentry=lightgray,black
    label=cyan,black
    listbox=white,black
    actlistbox=black,yellow
    sellistbox=yellow,black
    actsellistbox=black,yellow
    textbox=white,black
    acttextbox=black,yellow
    helpline=gray,black
    roottext=blue,black
    emptyscale=,gray
    fullscale=,blue
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
      hyprpolkitagent # polkit auth agent; without one, GUI polkit prompts (fprintd enroll, etc.) fail closed
      firefox
      slack
      emacs-pgtk
      emacs-lsp-booster
      vscode

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
      # On the PRIME laptops Chromium's GPU process picks up the NVIDIA EGL
      # vendor and hands Hyprland (compositing on the Intel iGPU) dmabufs it
      # can't import (EGL_BAD_MATCH), which hangs/aborts the compositor inside
      # mesa as soon as the window renders. A password manager gains nothing
      # from GPU compositing, so keep it off the GPU entirely.
      (symlinkJoin {
        name = "bitwarden-desktop";
        paths = [ bitwarden-desktop ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/bitwarden --add-flags --disable-gpu
        '';
      })
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
      picocom
      rclone
      wl-mirror

      #xfce
      blueman

      (pkgs.python3.withPackages (ps: with ps; [
        black
        debugpy # DAP adapter for Emacs `dape`
        setuptools
        packaging
        west # Zephyr/MCUXpresso SDK meta-tool; VS Code's MCUXpresso extension probes `python3 -m west`
      ]))
      pkgs.ruff
      pipx # install/run Python CLI apps in isolated venvs
      uv # fast Python package / project manager
      basedpyright # Python LSP: type-checking, completion, navigation
      nixd # Nix LSP server
      dasel # used by Emacs `pet` to parse pyproject.toml / detect venvs

      (aspellWithDicts (dicts: with dicts; [ en ]))

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
