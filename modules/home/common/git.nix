{ pkgs, ... }:
{
  home.packages = [
    pkgs.pass                     # gpg-encrypted store; git-credential-manager's "gpg" backend reads/writes it
    pkgs.git-credential-manager   # host-agnostic credential helper (GitHub, GitLab, anything HTTPS)
  ];

  programs.git = {
    enable = true;

    settings.user.name = "brennanmk";
    settings.user.email = "brennanmk2200@gmail.com";

    settings = {
      # git-credential-manager backed by pass/gpg: the token is encrypted at
      # rest (unlike plain git-credential-store) and persists across reboots
      # (unlike git-credential-cache), without needing a Secret Service
      # keyring daemon that autologin can't unlock on its own.
      credential.helper = "manager";
      credential.credentialStore = "gpg";
      # Force terminal prompts instead of GCM's GUI dialog.
      credential.guiPrompt = false;
    };
  };

  # Backs git-credential-manager's "gpg" store. pinentry-curses keeps the
  # passphrase prompt in-terminal, matching guiPrompt=false above. GnuPG has
  # no real "never expire" setting (0 isn't a no-op, it's an unrelated edge
  # case), so a 1-year TTL is the practical equivalent: the cache is
  # memory-only anyway, so a reboot clears it regardless of what this says.
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
    defaultCacheTtl = 31536000; # 1 year
    maxCacheTtl = 31536000;
  };
}
