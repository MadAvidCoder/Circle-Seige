extends Node

enum WindowModes {
	FULLSCREEN,
	WINDOWED,
	EXCLUSIVE_FULLSCREEN,
}

var palettes = {
	"cyber": {
		"bg_dark": Color("#0a080f"),
		"bg_light": Color("#d4c7ff"),
		"player": Color("#d91219"),
		"obstacles": Color("#d9a0d4"),
		"beat_obstacle": Color("#fe7b31"),
		"shockwave": Color("dd9400"),
		"spectrum": Color("50a9f0"),
		"near_miss": Color("fff2b3"),
		"telegraph_chord": Color("e633ff"),
		"telegraph_radial": Color("ff8033"),
		"selection": Color("33ff33"),
		"tooltip": Color("4dffcc"),
	},
	"ink": {
		"bg": Color("#fff8ea"),
		"accent": Color("#1b1b3a"),
		"danger": Color("#e94560"),
		"player": Color("#22223b"),
		"sector": Color("#726a95"),
		"tooltip": Color(0.21, 0.19, 0.18, 0.92)
	},
	"monochrome": {
		"bg": Color("#222"),
		"accent": Color("#ddd"),
		"danger": Color("#f55"),
		"player": Color("#eee"),
		"sector": Color("#888"),
		"tooltip": Color(0.8, 0.8, 0.8, 0.85)
	},
	"warmth": {
		"bg": Color("#3b1f2b"),
		"accent": Color("#fd6d3a"),
		"danger": Color("#e85d75"),
		"player": Color("#fff"),
		"sector": Color("#fecea8"),
		"tooltip": Color(1.0, 0.89, 0.66, 0.82)
	}
}

var cur_palette = "cyber"
var colours = palettes[cur_palette]

var particles = true
var camera_fx = true
var shockwave = true
var spectrum_line = true
var reduced_motion = false
var colourblind = false
var contrast = false
var window_mode = WindowModes.FULLSCREEN

func _ready() -> void:
	match window_mode:
		WindowModes.WINDOWED:
			Config.window_mode = Config.WindowModes.WINDOWED
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var window_size = Vector2i(1280, 720)
			DisplayServer.window_set_size(window_size)
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_position((screen_size - window_size) / 2)
		WindowModes.EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		WindowModes.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
