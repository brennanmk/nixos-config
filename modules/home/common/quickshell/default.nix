{ pkgs, config, ... }:
{
  # python3 with `pam` + `pygobject3` is provided by common/packages.nix,
  # shared with the dev-tooling python env to avoid a duplicate `python3`
  # binary colliding in the home-manager profile.
  home.packages = with pkgs; [
    quickshell
    socat
    poweralertd

    # bar / control-center widgets
    upower
    brightnessctl
    bluez
    gnome-keyring
    polkit_gnome

    # screenshot / clipboard modules
    grim
    slurp
    wl-clipboard
    cliphist

    # theming / wallpaper
    hyprpicker
    awww
    imagemagick
    glib # gsettings CLI
    gsettings-desktop-schemas # org.gnome.desktop.interface etc; without
    # this, every `gsettings set` in apply_theme.py is a silent no-op

    # dashboard widgets
    cava
    fastfetch
    activitywatch

    # QML module quickshell needs but doesn't bundle (Qt5Compat.GraphicalEffects)
    kdePackages.qt5compat
  ];

  # additive: lets Quickshell (and other QML apps) find Qt5Compat without
  # touching anyone else's QT_QPA_PLATFORM/theme session variables.
  home.sessionVariables.QML2_IMPORT_PATH = "${pkgs.kdePackages.qt5compat}/lib/qt-6/qml";

  xdg.configFile."quickshell" = {
    source = ./files;
    recursive = true;
  };

  # quickshell's WallpaperSelector hardcodes ~/Pictures/Wallpapers (capital W);
  # bridge it to the actual (lowercase) wallpapers directory instead of
  # patching every vendored QML/script reference.
  home.file."Pictures/Wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Pictures/wallpapers";

  xdg.dataFile."applications/minflair-keybinds.desktop".source = ./files/Applications/minflair-keybinds.desktop;
  xdg.dataFile."applications/minflair-settings.desktop".source = ./files/Applications/minflair-settings.desktop;
}
