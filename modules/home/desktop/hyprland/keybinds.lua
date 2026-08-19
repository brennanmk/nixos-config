local mainMod = "SUPER"

-- ## Applications

-- # Open Terminal
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
-- # Open Floating Terminal
hl.bind("ALT + Return", hl.dsp.exec_cmd("kitty --title float_kitty"))
-- # Open Fullscreen Terminal
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("kitty --start-as=fullscreen -o 'font_size=16'"))
-- # Open File Manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
-- # Search Firefox
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("wofi_firefox"))
-- # Open Network Manager TUI
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("kitty --class floating --override color0=#1e1e2e -e nmtui"))
-- # Open Monitor Manager
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("kitty --class floating -e hyprmon"))

-- ## Window Management

-- # Close Active Window
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- # Force Kill Active Window
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd("hyprctl activewindow -j | jq '.pid' | xargs kill -9"))
-- # Lock Screen
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_lockScreen"))
-- # Toggle Floating Mode
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
-- # Toggle Maximize Window
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
-- # Toggle True Fullscreen
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
-- # Pseudo Tiling Layout
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- # Toggle Split Direction
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
-- # Caffeinate (inhibit sleep)
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("caffeinate"))

-- ## Tools

-- # Power Menu
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_powerMenu"))
-- # Screenshot (region, save)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --notify --cursor --freeze save area ~/Pictures/$(date +'%Y-%m-%d-At-%Ih%Mm%Ss').png"))
-- # Screenshot (region, copy)
hl.bind("Print", hl.dsp.exec_cmd("grimblast --notify --cursor --freeze copy area"))

-- ## Volume

-- # Raise Volume
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume.sh up"),
	{ repeating = true, locked = true }
)
-- # Lower Volume
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume.sh down"),
	{ repeating = true, locked = true }
)
-- # Mute Speaker
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/volume.sh mute"), { locked = true })

-- ## Brightness

-- # Increase Brightness
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh up"),
	{ repeating = true, locked = true }
)
-- # Decrease Brightness
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/brightness.sh down"),
	{ repeating = true, locked = true }
)
-- # Increase Brightness (fast)
hl.bind(mainMod .. " + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 100%+"), { repeating = true, locked = true })
-- # Decrease Brightness (fast)
hl.bind(mainMod .. " + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 100%-"), { repeating = true, locked = true })

-- ## Media Player

-- # Play / Pause
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/media_player.sh play-pause"), { locked = true })
-- # Next Track
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/media_player.sh next"), { locked = true })
-- # Previous Track
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/media_player.sh prev"), { locked = true })
-- # Stop
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/media_player.sh stop"), { locked = true })

-- ## Quickshell Widgets

-- # Toggle App Launcher
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_launcher"))
-- # Toggle Control Center
hl.bind("CTRL + ALT + S", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_controlCenter"))
-- # Toggle Power Menu
hl.bind("CTRL + ALT + X", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_powerMenu"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_powerMenu"))
-- # Toggle Wallpaper Selector
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_wallpaper"))
-- # Toggle Screenshot
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_screenshot"))

-- ## Quickshell Apps

-- # Toggle Settings
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_minflair_settings"))
-- # Toggle Keybinds Cheat Sheet
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_minflair_keybinds"))
hl.bind("F1", hl.dsp.exec_cmd("socat - UNIX-CONNECT:/tmp/quickshell_minflair_keybinds"))

-- ## Navigation

-- # Move Focus ←→↑↓
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))

-- # Move Window Position ←→↑↓
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

-- # Resize Active Window ←→↑↓
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 80, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -80, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -80 }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 80 }), { repeating = true })

-- # Move Active Window ←→↑↓
hl.bind(mainMod .. " + ALT + left", hl.dsp.exec_cmd("hyprctl dispatch moveactive -80 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("hyprctl dispatch moveactive 80 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + up", hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 -80"), { repeating = true })
hl.bind(mainMod .. " + ALT + down", hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 80"), { repeating = true })

-- ## Workspaces

-- # Switch to Workspace 1..0
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- # Send Window to Workspace 1..0
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- ## Mouse Binds

-- # Drag to Move Window
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
-- # Drag to Resize Window
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
