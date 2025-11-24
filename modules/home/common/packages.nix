{ inputs, pkgs, ... }: 
{
  home.packages = (with pkgs; [
    bitwise                           # cli tool for bit / hex manipulation
    file                              # Show file information 
    hexdump
    jdk17                             
    nitch                             # systhem fetch util
    nix-prefetch-github
    ripgrep                           # grep replacement
    soundwireserver                   # pass audio to android phone
    teams-for-linux
    gimp
    # C / C++
    gcc
    gnumake
    cmake
    libtool
    lazysql

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
    cudatoolkit
    polybar
    htop
    obs-studio
    bitwarden-desktop
    sqlite
    prusa-slicer
    discord
    vesktop
    webcord
    obs-studio

    nodejs

    cargo
    rustc

    #image writing
    caligula

    # LLM magic
    ollama
    aider-chat

    unityhub

    #system utils
    bluetuith
    pulsemixer
    pavucontrol
    wdisplays
    nemo

    inotify-tools
    nvidia-container-toolkit
    texliveFull

    davfs2
    wofi
    picocom
    rclone
    wl-mirror

    #xfce
    blueberry

    # python
    pkgs.python3
    pkgs.python3Packages.black
    pkgs.python3Packages.pyflakes
    pkgs.python3Packages.epc
    pkgs.python3Packages.orjson
    pkgs.python3Packages.sexpdata
    pkgs.python3Packages.six
    pkgs.python3Packages.setuptools
    pkgs.python3Packages.paramiko
    pkgs.python3Packages.rapidfuzz
    pkgs.python3Packages.watchdog
    pkgs.python3Packages.packaging
    pyright
    ruff

    (aspellWithDicts (dicts: with dicts; [ 
        en 
        en-computers 
        en-science 
        ]))
    
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
