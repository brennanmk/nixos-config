{...}: let
  custom = {
    font = "JetBrainsMono Nerd Font";
    font_size = "20px";
    font_weight = "bold";
    text_color = "#cdd6f4";
    secondary_accent = "89b4fa";
    tertiary_accent = "f5f5f5";
    background = "11111";
  };
in {
  programs.waybar.style = ''
    * {
        border: none;
        border-radius: 0px;
        padding: 0;
        margin: 0;
        min-height: 0px;
        font-family: ${custom.font};
    }

    window#waybar {
        background: transparent;
        background-color: rgba(43, 48, 59, 0.5);
        color: #ffffff;
        transition-property: background-color;
        transition-duration: .5s;
    }

    #custom-sep,
    #custom-left-arrow,
    #custom-right-arrow {
        color: #1a1a1a;
        font-size: 20px;
    }

    #workspaces,
    #clock.1,
    #clock.2,
    #clock.3,
    #pulseaudio,
    #memory,
    #cpu,
    #battery,
    #disk,
    #network,
    #custom-notification,
    #tray,
    /* Added these to fix transparent background */
    #custom-screenshot,
    #custom-settings,
    #custom-power {
        background: #1a1a1a;
    }

    #workspaces {
        font-size: 18px;
        padding-left: 15px;
    }

    #workspaces button {
        color: ${custom.text_color};
        padding-left: 6px;
        padding-right: 6px;
    }

    #workspaces button.empty {
        color: #6c7086;
    }

    #workspaces button.active {
        color: #b4befe;
    }

    #clock,
    #pulseaudio,
    #memory,
    #cpu,
    #battery,
    #network,
    #tray,
    #custom-notification,
    #disk,
    /* Added these for consistent padding */
    #custom-screenshot,
    #custom-settings,
    #custom-power {
        padding: 0 10px;
    }
  '';
}
