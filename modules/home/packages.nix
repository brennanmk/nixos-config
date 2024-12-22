{ inputs, pkgs, ... }: 
{
  home.packages = (with pkgs; [
    bitwise                           # cli tool for bit / hex manipulation
    file                              # Show file information 
    hexdump
    jdk17                             # java
    nitch                             # systhem fetch util
    nix-prefetch-github
    ripgrep                           # grep replacement
    soundwireserver                   # pass audio to android phone
    valgrind                          # c memory analyzer
    yazi                              # terminal file manager
    gnome.zenity

    # C / C++
    gcc
    gnumake
    firefox
    slack
    emacs-gtk
    emacs-lsp-booster
    nodePackages.prettier

    spotify
    feh
    evince
    zotero
    discord
    polybar
    htop
    cudatoolkit
    obs-studio
    zerotierone
    bitwarden
    unityhub
    zoom-us
    sqlite
    nodejs
    prusa-slicer
    steam
    texliveFull
    #image writing
    caligula
    rpi-imager

    #xfce
    xfce.xfce4-pulseaudio-plugin
    blueberry
    devcontainer
    pkgs.python3
    pkgs.python3Packages.black
    pkgs.python3Packages.python-lsp-server
    pkgs.python3Packages.pyflakes
    jdt-language-server
    marksman
    nil
    dockerfile-language-server-nodejs
    docker-compose-language-service

    ollama-cuda
    zlib
    psmisc
    cmatrix
    gparted                           # partition manager
    ffmpeg
    imv                               # image viewer
    libnotify
	man-pages					            	  # extra man pages
    mpv                               # video player
    ncdu                              # disk space
    openssl
    pamixer                           # pulseaudio command line mixer
    playerctl                         # controller for media players
    unzip
    wget
    xdg-utils
    inputs.alejandra.defaultPackage.${system}
  ]);
}
