{ ... }:
{
  programs.waybar.settings.mainBar = {
    position= "top";
    layer= "top";
    height= 5;
    modules-left= [
        "custom/right-arrow-light"
        "hyprland/workspaces"
        "custom/right-arrow-dark"
    ];
    modules-center= [
        "custom/left-arrow-dark"
        "clock#1"
        "custom/left-arrow-light"
        "custom/right-arrow-light"
        "clock#2"

        "custom/left-arrow-light"
        "custom/right-arrow-light"
        "clock#3"
        "custom/right-arrow-dark"
    ];
    modules-right= [
        "custom/left-arrow-dark"
        "network"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "pulseaudio"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "disk"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "battery"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "custom/notification"
        "custom/left-arrow-light"
    ];
    memory= {
        format= "󰟜 {}%";
        format-alt= "󰟜 {used} GiB"; # 
        interval= 2;
    };
    cpu= {
        format= "  {usage}%";
        format-alt= "  {avg_frequency} GHz";
        interval= 5;
    };
    disk = {
        # path = "/";
        format = "󰋊 {percentage_used}%";
        interval= 60;
    };
    network = {
        format-wifi = "  Connected";
        format-ethernet = "󰀂  Connected";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "󰖪  Disconnected";
    };
    tray= {
        icon-size= 20;
    };
    pulseaudio= {
        format= "{icon}  {volume:2}%";
        format-muted= "  {volume}%";
        format-icons= {
            default= [""];
        };
        scroll-step= 5;
        on-click="kitty --class floating -e pulsemixer";
    };
    battery = {
        format = "{icon} {capacity}% ";
        format-icons = [" " " " " " " " " "];
        format-charging = " {capacity}% ";
        format-full = " {capacity}% ";
        format-warning = " {capacity}% ";
        interval = 5;
        states = {
            warning = 20;
        };
        format-time = "{H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
    };

    "custom/left-arrow-dark" = {
        "format"= "";
        "tooltip"= false;
    };

    "custom/left-arrow-light"= {
        "format"= "";
        "tooltip"= false;
    };
    "custom/right-arrow-dark"= {
        "format"= "";
        "tooltip"= false;
    };
    "custom/right-arrow-light"= {
        "format"= "";
        "tooltip"= false;
    };


    "clock#1"= {
        "format"= "{:%a}";
        "tooltip"= false;
    };
    "clock#2"= {
        "format"= "{:%I:%M}";
        "tooltip"= false;
    };
    "clock#3"= {
        "format"= "{:%m-%d}";
        "tooltip"= false;
    };


    "custom/notification" = {
        tooltip = false;
        format = "{icon} ";
        format-icons = {
            notification = "";
            none = "";
            dnd-notification = "";
            dnd-none = "";
            inhibited-notification = "";
            inhibited-none = " ";
            dnd-inhibited-notification = "";
            dnd-inhibited-none = "";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
    };
  };
}
