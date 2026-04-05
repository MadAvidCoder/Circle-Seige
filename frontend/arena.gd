extends Node2D

@export var radius: float = 320
@export var thickness: float = 6

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 128, Color(0.9, 0.9, 1.0, 0.9), thickness, true)

func _process(delta: float) -> void:
	queue_redraw()
