extends Node2D

@export var spectrum_height := 1000.0
@export var y_offset := 0.0

@onready var main = $".."
@onready var stream = $"../AudioStreamPlayer"

@onready var width = get_viewport_rect().size.x * 0.95
@onready var x_offset = get_viewport_rect().size.x * 0.05 / 2

func _draw() -> void:
	var time = stream.get_playback_position()
	var bins = main.get_spectrum(time)
	if bins.size() == 0:
		return
	
	var n_bins = bins.size() * 0.7
	var pts = []
	
	var max_val = 0.0
	for b in bins:
		max_val = max(max_val, b)
	max_val = max(max_val, 1e-6)
		
	for i in range(n_bins):
		var x = width * float(i) / float(n_bins-1)
		var val = bins[i]
		var db = log(val + 1e-6)
		var y = y_offset - clamp((db + 5.0) / 10.0, 0, 1) * spectrum_height
		pts.append(Vector2(x, y))
	
	draw_polyline(pts, Color(0.5,0.7,1,0.75), 2.5, true)

func _process(delta: float) -> void:
	queue_redraw()
