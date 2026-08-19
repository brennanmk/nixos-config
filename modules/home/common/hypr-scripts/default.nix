{ ... }:
{
  xdg.configFile."hypr/scripts/volume.sh" = {
    source = ./volume.sh;
    executable = true;
  };
  xdg.configFile."hypr/scripts/brightness.sh" = {
    source = ./brightness.sh;
    executable = true;
  };
  xdg.configFile."hypr/scripts/media_player.sh" = {
    source = ./media_player.sh;
    executable = true;
  };
}
