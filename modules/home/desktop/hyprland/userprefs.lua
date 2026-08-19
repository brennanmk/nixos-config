hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 1,
		["col.active_border"] = "rgb(cba6f7)",
		["col.inactive_border"] = "0x00000000",
	},
	decoration = {
		rounding = 0,
		active_opacity = 1,
		inactive_opacity = 1,
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
		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
		},
	},
	dwindle = {
		force_split = 0,
		smart_split = true,
		special_scale_factor = 1.0,
		split_width_multiplier = 1.0,
		use_active_for_splits = true,
		preserve_split = true,
	},
	master = {
		new_status = "master",
		special_scale_factor = 1,
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
	input = {
		kb_layout = "us",
		numlock_by_default = true,
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
	xwayland = {
		force_zero_scaling = true,
	},
	animations = {
		enabled = true,
	},
})
