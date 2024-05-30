{ inputs, pkgs, ... }: 
{
  home.packages = (with pkgs; [
    bitwise                           # cli tool for bit / hex manipulation
    file                              # Show file information 
    hexdump
    jdk17                             # java
    cinnamon.nemo-with-extensions     # file manager
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
    enpass
    slack
    emacs29
    spotify
    feh
    evince
    zotero
    discord
    polybar
    obsidian
    htop
    cudatoolkit
    obs-studio
    zerotierone
    bitwarden
    unityhub
    zoom-us
    sqlite

    #xfce
    xfce.xfce4-pulseaudio-plugin
    blueberry

    python312
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
