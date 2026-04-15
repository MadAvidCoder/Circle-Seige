extends Line2D

var start_radius = 0.0
var end_radius = 0.0
var duration = 0.33
var elapsed = 0.0
var active = false

func fire(sr, er, c):
	start_radius = sr
	end_radius = er
	elapsed = 0.0
	active = true
	modulate = c
	update_ring_points(start_radius)

func update_ring_points(radius):
	var p_count = 80
	points = []
	var x = []
	for i in range(p_count):
		var phi = TAU* i/p_count
		x.append(Vector2(cos(phi), sin(phi)) * radius)
	points = x

func _process(delta: float) -> void:
	if !active:
		return
	
	elapsed += delta
	var t = elapsed / duration
	if t >= 1.0:
		active = false
		visible = false
		return
	
	var radius = lerp(start_radius, end_radius, t)
	modulate.a = lerp(0.94, 0.0, t)
	update_ring_points(radius)
	visible = true
