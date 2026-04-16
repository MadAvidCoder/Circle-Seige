extends Node2D

@export var radius = 400
@export var thickness = 6

@export var option_font: Font
@export var option_selected_font: Font
@export var option_color = Color(0.85, 0.9, 1.0, 0.72)
@export var option_selected_color = Color(0.3, 1.0, 0.8, 1.0)
@export var label_padding = 42.0 
@export var font_size = 38

var segments = 4

var options = [
	{"label": "Play", "tooltip": "Start the game and choose your mode!"},
	{"label": "Settings", "tooltip": "Configure color, VFX, accessibility, and more."},
	{"label": "Credits/Help", "tooltip": "Learn about the game."},
	{"label": "Quit", "tooltip": "Exit the game."},
]

var sector_size = TAU / segments
var angle_offset = -PI / 2.0 - (sector_size / 2.0)

@onready var player = $"../Player"

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0,0,0,0.2))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 128, Color(0.9, 0.9, 1.0, 0.9), thickness, true)
	
	for i in range(segments):
		var a = angle_offset + i * sector_size
		var dir = Vector2(cos(a), sin(a))
		draw_line(Vector2.ZERO, dir * radius, Color(0.8, 0.8, 1.0, 0.6), 3.0)

	var local_pos = to_local(player.global_position)
	var angle = atan2(local_pos.y, local_pos.x)
	if angle < 0:
		angle += TAU

	var adjusted_angle = angle - angle_offset
	adjusted_angle = fposmod(adjusted_angle, TAU)
	
	var sector_index = int(adjusted_angle / sector_size)
	
	var start = angle_offset + sector_index * sector_size
	var end = start + sector_size
	
	var pts = []
	pts.append(Vector2.ZERO)
	for i in range(49):
		var a = lerpf(start, end, float(i) / 48.0)
		pts.append(Vector2(cos(a), sin(a)) * radius)
	
	draw_colored_polygon(pts, Color(0.2, 1.0, 0.2, 0.4))
	draw_arc(Vector2.ZERO, radius, start, end, 64, Color.GREEN, 2.0)
	
	for i in range(options.size()):
		var a = angle_offset + (i + 0.5) * sector_size
		var dir = Vector2(cos(a), sin(a))

		var is_selected = (i == sector_index)
		var col = option_selected_color if is_selected else option_color
		var font = option_selected_font if is_selected && option_selected_font != null else option_font

		var text = options[i].label
		var text_size = font.get_string_size(text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)

		var dx = text_size.x / 2
		var dy = text_size.y / 2
		var corners = [
			Vector2(-dx, -dy),
			Vector2(dx, -dy),
			Vector2(dx, dy),
			Vector2(-dx, dy)
		]

		var anchor_offset = 0.0
		for c in corners:
			anchor_offset = max(anchor_offset, c.dot(dir))
		
		var box_center_dist = radius - label_padding - anchor_offset
		var box_center = dir * box_center_dist

		var label_pos = box_center - Vector2(text_size.x / 2, text_size.y / 2)
		
		var ascent = font.get_ascent(font_size)
		draw_string(font, label_pos+Vector2(0, ascent), text, HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)
	
	if sector_index < options.size() and options[sector_index].has("tooltip"):
		var message = options[sector_index].tooltip
		var tooltip_font = option_font
		var tooltip_size = tooltip_font.get_string_size(message) if tooltip_font != null else Vector2(0,0)
		
		var ypos = radius + 72
		var tooltip_width = get_viewport_rect().size.x
		draw_string(option_font, Vector2(-tooltip_width/2, ypos), message, HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, tooltip_width, 26, Color(0.7, 1.0, 0.9, 0.78))
