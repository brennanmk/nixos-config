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
    zenity
    polychromatic

    # C / C++
    gcc
    gnumake
    cmake
    libtool

    # general appliactions
    firefox
    slack
    emacs30-pgtk

    spotify
    feh
    evince
    zotero
    libreoffice
    htop
    cudatoolkit
    polybar
    htop
    cudatoolkit
    obs-studio
    zerotierone
    bitwarden
    sqlite
    prusa-slicer
    vesktop
    obs-studio

    nodejs
    nodePackages.prettier

    cargo
    rustc

    prusa-slicer

    #image writing
    caligula

    #system utils
    bluetuith
    pulsemixer
    pavucontrol
    wdisplays
    nautilus

    python3
    python3Packages.black
    python3Packages.python-lsp-server
    python3Packages.pyflakes
    python3Packages.mysqlclient
    erlang
    erlang-ls
    rebar3
    elixir
    elixir-ls
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
