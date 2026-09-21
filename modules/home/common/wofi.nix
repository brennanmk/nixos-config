{ ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      allow_images = true;
      allow_markup = true;
      insensitive = true;
      matching = "fuzzy";
      hide_scroll = true;
      no_actions = true;
      term = "kitty";
      width = "35%";
      height = "45%";
      location = "center";
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 14px;
      }

      window {
        background-color: #1e1e2e;
        border: 2px solid #cba6f7;
        border-radius: 8px;
      }

      #input {
        margin: 8px;
        padding: 8px;
        border: none;
        border-radius: 6px;
        background-color: #313244;
        color: #cdd6f4;
      }

      #inner-box {
        margin: 0 8px 8px 8px;
        background-color: transparent;
      }

      #outer-box {
        margin: 4px;
        background-color: transparent;
      }

      #scroll {
        background-color: transparent;
      }

      #entry {
        padding: 6px;
        border-radius: 6px;
      }

      #entry:selected {
        background-color: #cba6f7;
      }

      #entry:selected #text {
        color: #1e1e2e;
      }

      #img {
        margin-right: 8px;
      }

      #text {
        color: #cdd6f4;
      }
    '';
  };
}
