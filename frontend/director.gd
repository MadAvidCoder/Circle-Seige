extends Node2D

@export var gap_width_deg: float = 40.0  
@export var gap_margin_deg: float = 10.0
@export var min_gap_window: float = 0.75

@export var debug_draw_gap: bool = true
@export var debug_gap_alpha: float = 0.22

@onready var arena = $"../Arena"
@onready var player = $"../Player"

var song_time = 0.0
var gap_centre = 0.0
var gap_until_t = 0.0

func _ready() -> void:
	gap_centre = (player.global_position - arena.global_position).angle()

func _process(delta: float) -> void:
	song_time += delta
	
	if song_time > gap_until_t:
		var target = (player.global_position - arena.global_position).angle()
		gap_centre = lerp_angle(gap_centre, target, 0.18)
		
	if debug_draw_gap:
		queue_redraw()

func lock_gap(time: float) -> void:
	gap_until_t = maxf(gap_until_t, song_time+maxf(time, min_gap_window))

func get_gap_width_rad() -> float:
	return deg_to_rad(gap_width_deg)

func get_gap_effective_width_rad() -> float:
	return deg_to_rad(gap_width_deg + 2.0 * gap_margin_deg)

func is_angle_in_gap(theta: float, t: float = -1.0) -> bool:
	if t < 0.0:
		t = song_time
	
	if t >= gap_until_t:
		return false
	
	var w = get_gap_effective_width_rad()
	var half = w * 0.5
	
	return absf(wrapf(theta - gap_centre, -PI, PI)) <= half

func nearest_angle_outside_gap(theta: float) -> float:
	var w = get_gap_effective_width_rad()
	var half = w * 0.5
	var d = wrapf(theta - gap_centre, -PI, PI)
	
	if absf(d) > half:
		return theta
	
	var sign = 1.0 if d >= 0.0 else -1.0
	var eps = deg_to_rad(0.5)
	return gap_centre + sign * (half + eps)

func _draw() -> void:
	if !debug_draw_gap:
		return
	
	var r = arena.radius
	var w = get_gap_effective_width_rad()
	var start = gap_centre - w * 0.5
	var end = gap_centre + w * 0.5
	
	var col = Color(0.2, 1.0, 0.2, debug_gap_alpha)
	
	var pts = []
	pts.append(Vector2.ZERO)

	for i in range(49):
		var a = lerpf(start, end, float(i) / float(48))
		pts.append(Vector2(cos(a), sin(a)) * r)
	
	draw_colored_polygon(pts, col)
	
	draw_arc(Vector2.ZERO, r, start, end, 64, Color(0.2, 1.0, 0.2, 0.9), 2.0, true)
