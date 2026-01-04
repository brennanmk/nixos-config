{ config, pkgs, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      "font" = "JetBrainsMono Nerd Font 12";
      "width" = 500;
      "padding" = 8;
      "margin" = "5,5,10,0";
      "anchor" = "top-right";
      "layer" = "overlay";
      "format" = "<b>%s</b>\\n%b";
      "markup" = 1;
      "border-size" = 2;
      "icons" = 1;
      "max-icon-size" = 64;
      "background-color" = "#2b303b";
      "text-color" = "#cdd6f4";
      "border-color" = "#89b4fa";
      "default-timeout" = 5000;
      "ignore-timeout" = 1;
      
      "urgency=low" = {
        "border-color" = "#b7bdf8";
        "default-timeout" = 3000;
      };
      "urgency=normal" = {
        "border-color" = "#b7bdf8";
        "default-timeout" = 5000;
      };
      "urgency=critical" = {
        "border-color" = "#b7bdf8";
        "default-timeout" = 0;
      };
    };
  };
}
