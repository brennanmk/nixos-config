{pkgs, ...}: let
  # wofi_settings / wofi_power / wofi_capture were dropped: superseded by
  # quickshell's Settings app, PowerMenu, and Screenshot modules.
  wofi_firefox = pkgs.writeShellScriptBin "wofi_firefox" (builtins.readFile ./scripts/wofi_firefox.sh);
  caffeinate = pkgs.writeShellScriptBin "caffeinate" (builtins.readFile ./scripts/caffeinate.sh);

  record = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
  update-ollama = pkgs.writeShellScriptBin "update-ollama" (builtins.readFile ./scripts/update-ollama.sh);
in {
  home.packages = with pkgs; [
    wofi_firefox
    caffeinate
    record
    update-ollama
  ];
}
