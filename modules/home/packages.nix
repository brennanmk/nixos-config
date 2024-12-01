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
    polychromatic

    # C / C++
    gcc
    gnumake

    # general appliactions
    firefox
    enpass
    slack
    emacs29-pgtk
    emacs-lsp-booster
    libreoffice
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
    sqlite
    nodejs
    prusa-slicer

    cargo
    rustc

    #image writing
    caligula
    rpi-imager
    texlive.combined.scheme-full
    swayidle
    sway-audio-idle-inhibit

    #system utils
    bluetuith
    pulsemixer
    pavucontrol
    wdisplays

    python3
    python3Packages.black
    python3Packages.python-lsp-server
    python3Packages.pyflakes
    python3Packages.mysqlclient

    jetbrains.idea-ultimate

    davfs2

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
    inputs.alejandra.defaultPackage.${system}
  ]);
}
