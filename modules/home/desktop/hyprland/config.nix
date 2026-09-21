{ pkgs, lib, config, ... }:
{
  # hyprmon (Super+D) checks for an exact-match `require("hyprmon")` line
  # before it'll skip rewriting hyprland.lua (which would fail: that file is
  # our immutable home-manager symlink). It only ever adds that line right
  # after first writing hyprmon.lua itself, so on a machine that's never run
  # hyprmon yet the require below would error at Hyprland startup. Seed an
  # empty sidecar once, without ever clobbering hyprmon's own saved layout on
  # later rebuilds.
  home.activation.ensureHyprmonLua = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/hypr"
    if [ ! -e "$HOME/.config/hypr/hyprmon.lua" ]; then
      run touch "$HOME/.config/hypr/hyprmon.lua"
    fi
  '';

  # hyprmon unconditionally rewrites hyprland.lua on every save (it has no
  # "already up to date, skip" branch) — that write fails outright against
  # home-manager's normal symlink into the read-only Nix store, no matter
  # what content is already there. Swap the symlink for a real copy so the
  # write succeeds; safe to redo on every rebuild since hyprmon's rewrite is
  # a byte-for-byte no-op once the require("hyprmon") line is present above.
  home.activation.hyprlandLuaWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run rm -f "$HOME/.config/hypr/hyprland.lua"
    run install -m644 "${config.xdg.configFile."hypr/hyprland.lua".source}" "$HOME/.config/hypr/hyprland.lua"
  '';

  wayland.windowManager.hyprland = {
    extraConfig = ''
      ------------------
      ---- MONITORS ----
      ------------------

      hl.monitor({ output = "DP-2",     mode = "3440x1440@165.00", position = "1440x0", scale = "1" })
      hl.monitor({ output = "HDMI-A-1", mode = "3840x2160",        position = "0x0",    scale = "1.5", transform = 1 })
      hl.monitor({ output = "DP-1",     mode = "3840x2160",        position = "4880x0", scale = "1.5", transform = 3 })

      -- Load whatever layout the hyprmon TUI (Super+D) last saved, overriding
      -- the fallback above. hyprmon.lua is a plain file it manages itself
      -- (not home-manager), so this survives `home-manager switch`. Must be
      -- this exact line (hyprmon checks for it verbatim) so hyprmon never
      -- tries to rewrite this (immutable, Nix-owned) file itself.
      -- hyprmon: managed monitor profile include
      require("hyprmon")

      hl.config({
        xwayland = {
          force_zero_scaling = true,
        },
      })

      -------------------
      ---- AUTOSTART ----
      -------------------

      hl.on("hyprland.start", function()
        hl.exec_cmd("systemctl --user import-environment &")
        hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null &")
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &")
        hl.exec_cmd("${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent &")
        hl.exec_cmd("nm-applet &")
        hl.exec_cmd("hyprctl setcursor Nordzy-cursors 22 &")
        hl.exec_cmd("poweralertd &")
        hl.exec_cmd("waybar &")
        hl.exec_cmd("mako &")
        hl.exec_cmd("emacs --daemon")
        hl.exec_cmd("hyprlock")
      end)

      -----------------------
      ---- LOOK AND FEEL ----
      -----------------------

      hl.config({
        input = {
          kb_layout = "us,fr",
          kb_options = "grp:alt_caps_toggle",
          numlock_by_default = true,
          follow_mouse = 1,
          sensitivity = 0,
          touchpad = {
            natural_scroll = true,
          },
        },

        general = {
          layout = "dwindle",
          gaps_in = 2,
          gaps_out = 4,
          border_size = 1,
          col = {
            active_border = "rgb(cba6f7)",
            inactive_border = "0x00000000",
          },
        },

        misc = {
          disable_autoreload = true,
          disable_hyprland_logo = true,
          always_follow_on_dnd = true,
          layers_hog_keyboard_focus = true,
          animate_manual_resizes = false,
          enable_swallow = true,
          focus_on_activate = true,
          disable_splash_rendering = true,
        },

        dwindle = {
          force_split = 0,
          smart_split = true,
          split_width_multiplier = 1.0,
          use_active_for_splits = true,
          preserve_split = true,
        },

        master = {
          new_status = "master",
        },

        decoration = {
          rounding = 0,

          blur = {
            enabled = true,
            size = 1,
            passes = 1,
            brightness = 1,
            contrast = 1.400,
            ignore_opacity = true,
            noise = 0,
            new_optimizations = true,
            xray = true,
          },
        },

        animations = {
          enabled = true,
        },
      })

      -- bezier curves
      hl.curve("fluent_decel",  { type = "bezier", points = { {0, 0.2},  {0.4, 1}  } })
      hl.curve("easeOutCirc",   { type = "bezier", points = { {0, 0.55}, {0.45, 1} } })
      hl.curve("easeOutCubic",  { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
      hl.curve("easeinoutsine", { type = "bezier", points = { {0.37, 0}, {0.63, 1} } })

      -- animations
      hl.animation({ leaf = "windowsIn",   enabled = true,  speed = 3,   bezier = "easeOutCubic",  style = "popin 30%" }) -- window open
      hl.animation({ leaf = "windowsOut",  enabled = true,  speed = 3,   bezier = "fluent_decel",  style = "popin 70%" }) -- window close
      hl.animation({ leaf = "windowsMove", enabled = true,  speed = 2,   bezier = "easeinoutsine", style = "slide" })     -- moving, dragging, resizing
      hl.animation({ leaf = "fadeIn",      enabled = true,  speed = 3,   bezier = "easeOutCubic" })
      hl.animation({ leaf = "fadeOut",     enabled = true,  speed = 2,   bezier = "easeOutCubic" })
      hl.animation({ leaf = "fadeSwitch",  enabled = false, speed = 1,   bezier = "easeOutCirc" })
      hl.animation({ leaf = "fadeShadow",  enabled = true,  speed = 10,  bezier = "easeOutCirc" })
      hl.animation({ leaf = "fadeDim",     enabled = true,  speed = 4,   bezier = "fluent_decel" })
      hl.animation({ leaf = "border",      enabled = true,  speed = 2.7, bezier = "easeOutCirc" })
      hl.animation({ leaf = "borderangle", enabled = true,  speed = 30,  bezier = "fluent_decel", style = "once" })
      hl.animation({ leaf = "workspaces",  enabled = true,  speed = 4,   bezier = "easeOutCubic", style = "fade" })

      ---------------------
      ---- KEYBINDINGS ----
      ---------------------

      local mainMod = "SUPER"

      -- show keybinds list
      hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("show-keybinds"))

      -- keybindings
      hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd("kitty"))
      hl.bind("ALT + Return",                 hl.dsp.exec_cmd("kitty --title float_kitty"))
      hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty --start-as=fullscreen -o 'font_size=16'"))
      hl.bind(mainMod .. " + Q",              hl.dsp.window.close())
      hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.exec_cmd("hyprctl activewindow -j | jq '.pid' | xargs kill -9"))
      hl.bind(mainMod .. " + F",              hl.dsp.window.fullscreen({ mode = "fullscreen" }))
      hl.bind(mainMod .. " + SHIFT + F",      hl.dsp.window.fullscreen({ mode = "maximized" }))
      hl.bind(mainMod .. " + Space",          hl.dsp.window.float())
      hl.bind(mainMod .. " + R",              hl.dsp.exec_cmd("wofi --show drun"))
      hl.bind(mainMod .. " + S",              hl.dsp.exec_cmd("wofi_settings"))
      hl.bind(mainMod .. " + B",              hl.dsp.exec_cmd("wofi_firefox"))
      hl.bind(mainMod .. " + C",              hl.dsp.exec_cmd("wofi_capture"))
      hl.bind(mainMod .. " + SHIFT + C",      hl.dsp.exec_cmd("caffeinate"))
      hl.bind(mainMod .. " + SHIFT + N",      hl.dsp.exec_cmd("org-capture"))
      hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("shutdown-script"))
      hl.bind(mainMod .. " + P",              hl.dsp.window.pseudo())
      hl.bind(mainMod .. " + J",              hl.dsp.layout("togglesplit"))
      hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd("nemo"))
      hl.bind(mainMod .. " + N",              hl.dsp.exec_cmd("kitty --class floating --override color0=#1e1e2e -e nmtui"))
      hl.bind(mainMod .. " + D",              hl.dsp.exec_cmd("kitty --class floating -e hyprmon-apply"))
      hl.bind(mainMod .. " + SHIFT + B",      hl.dsp.exec_cmd("pkill -SIGUSR1 .waybar-wrapped"))
      hl.bind(mainMod .. " + L",              hl.dsp.exec_cmd("hyprlock"))

      -- screenshot
      hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --notify --cursor --freeze save area ~/Pictures/$(date +'%Y-%m-%d-At-%Ih%Mm%Ss').png"))
      hl.bind("Print",               hl.dsp.exec_cmd("grimblast --notify --cursor --freeze copy area"))

      -- switch focus
      hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
      hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
      hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

      -- switch workspace / move window to workspace [1-10]
      for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      -- window control
      hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
      hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
      hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

      hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -80, y = 0,   relative = true }))
      hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 80,  y = 0,   relative = true }))
      hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -80, relative = true }))
      hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 80,  relative = true }))

      hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ x = -80, y = 0,   relative = true }))
      hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ x = 80,  y = 0,   relative = true }))
      hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.move({ x = 0,   y = -80, relative = true }))
      hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.move({ x = 0,   y = 80,  relative = true }))

      -- media and volume controls
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 2"))
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 2"))
      hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"))
      hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
      hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
      hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))
      hl.bind("XF86AudioStop",        hl.dsp.exec_cmd("playerctl stop"))

      hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
      hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

      -- laptop brightness keys
      hl.bind("XF86MonBrightnessUp",               hl.dsp.exec_cmd("brightnessctl set 5%+"))
      hl.bind("XF86MonBrightnessDown",              hl.dsp.exec_cmd("brightnessctl set 5%-"))
      hl.bind(mainMod .. " + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 100%+"))
      hl.bind(mainMod .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 100%-"))

      -- mouse binds
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      --------------------------------
      ---- WINDOWS AND WORKSPACES ----
      --------------------------------

      hl.window_rule({
        name  = "floating-center",
        match = { class = "^(floating)$" },
        float  = true,
        center = true,
        size   = "800 600",
      })

      hl.window_rule({
        name  = "org-capture-center",
        match = { title = "^(org-capture)$" },
        float  = true,
        center = true,
        size   = "900 350",
      })
    '';
  };
}
