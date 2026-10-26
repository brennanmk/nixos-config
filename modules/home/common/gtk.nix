{ pkgs, config, ... }:
let
  monolisa = pkgs.callPackage ../../pkgs/monolisa/monolisa.nix { };
  monolisa-nerd = pkgs.callPackage ../../pkgs/monolisa/monolisa-nerd.nix {
    inherit monolisa;
  };
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    twemoji-color-font
    noto-fonts-color-emoji
  ];

  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "black"; };
    };
    cursorTheme = {
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 22;
    };
    gtk4.theme = config.gtk.theme;

    # A dark GTK theme name alone doesn't flip this boolean. Firefox and
    # Electron apps (Slack, Discord, ...) check gtk-application-prefer-dark-theme
    # (directly, or via the xdg-desktop-portal "Settings" interface) to decide
    # light vs. dark chrome/content — without it they default to light.
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = true;
    gtk4.extraConfig."gtk-application-prefer-dark-theme" = true;
  };

  # Same signal via dconf: xdg-desktop-portal-gtk reads this to answer the
  # freedesktop Settings portal (org.freedesktop.appearance color-scheme),
  # which is how sandboxed/Electron apps ask "is the system in dark mode?".
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Dracula";
    icon-theme = "Papirus-Dark";
  };

  # Qt apps (bitwarden-desktop, zotero, prusa-slicer, obs-studio, libreoffice)
  # were pointed at QT_QPA_PLATFORMTHEME=qt5ct/kvantum with neither package
  # installed nor configured, so Qt silently fell back to its light default
  # style. This makes Qt follow the same GTK theme instead.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  home.pointerCursor = {
    enable = true;
    name = "Nordzy-cursors";
    package = pkgs.nordzy-cursor-theme;
    size = 22;
  };
}
