{ ... }: 
{
  security.rtkit.enable = true;
  security.sudo.enable = true;
  # hyprlock talks to fprintd directly over D-Bus (auth.fingerprint block in
  # hyprlock.conf) rather than through PAM, so fprintAuth is turned off here
  # to stop pam_fprintd from also trying to claim the sensor and racing it.
  security.pam.services.hyprlock = {
    fprintAuth = false;
  };
}
