{ ... }:
{ inputs, pkgs, ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_USE_OZONE = "1";
    OZONE_PLATFORM = "wayland";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    _JAVA_AWT_WM_NONEREPARENTING = "1";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    DISABLE_QT5_COMPAT = "0";
    GDK_BACKEND = "wayland";
    DIRENV_LOG_FORMAT = "";
    WLR_DRM_NO_ATOMIC = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "xcb";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND="direct";
    CLUTTER_BACKEND = "wayland";
    GTK_THEME = "Dracula";
    HYPRCURSOR_SIZE="28";
    HYPRCURSOR_THEME="rose-pine-hyprcursor";
    LSP_BRIDGE_PYTHON_COMMAND = "${pkgs.python3.withPackages (p: with p; [ pkgs.epc ])}/bin/python";
  };
}
