extends Node2D

@export var nominal_radius: float = 320
@export var thickness: float = 6
@export var smooth_factor: float = 0.18

var radius = nominal_radius

@onready var main = $".."
@onready var stream = $"../AudioStreamPlayer"
@onready var timer = $Timer

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 128, Color(0.9, 0.9, 1.0, 0.9), thickness, true)

func _process(delta: float) -> void:
	queue_redraw()
	var target_radius = nominal_radius * (1 + 0.3 * main.energy)
	radius = lerp(radius, target_radius, smooth_factor)

func pulse():
	modulate = Color(1.0, 0.9, 0.7)
	timer.start()

func _on_timer_timeout() -> void:
	modulate = Color(1, 1, 1)
