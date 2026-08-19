{ ... }:
{
  # Curves/speeds carried over from the pre-quickshell hyprlang config so the
  # feel doesn't regress to Hyprland's slower stock animation defaults.
  wayland.windowManager.hyprland.settings = {
    curve = [
      { _args = [ "fluent_decel" { type = "bezier"; points = [ [ 0 0.2 ] [ 0.4 1 ] ]; } ]; }
      { _args = [ "easeOutCirc" { type = "bezier"; points = [ [ 0 0.55 ] [ 0.45 1 ] ]; } ]; }
      { _args = [ "easeOutCubic" { type = "bezier"; points = [ [ 0.33 1 ] [ 0.68 1 ] ]; } ]; }
      { _args = [ "easeinoutsine" { type = "bezier"; points = [ [ 0.37 0 ] [ 0.63 1 ] ]; } ]; }
    ];

    animation = [
      { leaf = "windowsIn"; enabled = true; speed = 3; bezier = "easeOutCubic"; style = "popin 30%"; }
      { leaf = "windowsOut"; enabled = true; speed = 3; bezier = "fluent_decel"; style = "popin 70%"; }
      { leaf = "windowsMove"; enabled = true; speed = 2; bezier = "easeinoutsine"; style = "slide"; }
      { leaf = "fadeIn"; enabled = true; speed = 3; bezier = "easeOutCubic"; }
      { leaf = "fadeOut"; enabled = true; speed = 2; bezier = "easeOutCubic"; }
      { leaf = "fadeSwitch"; enabled = false; speed = 1; bezier = "easeOutCirc"; }
      { leaf = "fadeShadow"; enabled = true; speed = 10; bezier = "easeOutCirc"; }
      { leaf = "fadeDim"; enabled = true; speed = 4; bezier = "fluent_decel"; }
      { leaf = "border"; enabled = true; speed = 2.7; bezier = "easeOutCirc"; }
      { leaf = "borderangle"; enabled = true; speed = 30; bezier = "fluent_decel"; style = "once"; }
      { leaf = "workspaces"; enabled = true; speed = 4; bezier = "easeOutCubic"; style = "fade"; }
    ];
  };
}
