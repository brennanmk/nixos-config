{pkgs, ...}: let
  wofi_settings = pkgs.writeShellScriptBin "wofi_settings" (builtins.readFile ./scripts/wofi_settings.sh);
  wofi_power = pkgs.writeShellScriptBin "wofi_power" (builtins.readFile ./scripts/wofi_power.sh);
  wofi_firefox = pkgs.writeShellScriptBin "wofi_firefox" (builtins.readFile ./scripts/wofi_firefox.sh);
  wofi_capture = pkgs.writeShellScriptBin "wofi_capture" (builtins.readFile ./scripts/wofi_capture.sh);
  caffeinate = pkgs.writeShellScriptBin "caffeinate" (builtins.readFile ./scripts/caffeinate.sh);

  record = pkgs.writeScriptBin "record" (builtins.readFile ./scripts/record.sh);
  update-ollama = pkgs.writeShellScriptBin "update-ollama" (builtins.readFile ./scripts/update-ollama.sh);
in {
  home.packages = with pkgs; [
    wofi_settings
    wofi_capture
    wofi_power
    wofi_firefox
    caffeinate
    record
    update-ollama
  ];
}
