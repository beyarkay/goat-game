class_name CableCar
extends Path2D

@export_range(0.5, 1.5) var speed: float = 1.0
@export_range(0, 1) var start_fraction: float = 0
@export_range(0, 1) var end_fraction: float = 1

@onready var line: Line2D = $line as Line2D
@onready var mover: AnimationPlayer = $PathFollow2D/mover
@onready var rail_sound: AudioStreamPlayer2D = $rail_sound as AudioStreamPlayer2D
@onready var pitch_shift_timer: Timer = $pitch_shift_timer as Timer

func _ready() -> void:
	line.points = curve.get_baked_points()
	mover.speed_scale = speed
	var move_animation := mover.get_animation("move_platform")
	move_animation.track_set_key_value(0, 0, start_fraction)
	move_animation.track_set_key_value(0, 1, end_fraction)
	move_animation.track_set_key_value(0, 2, start_fraction)

func _on_pitch_shift_timer_timeout() -> void:
	rail_sound.pitch_scale = randf_range(0.8, 1.2)
	pitch_shift_timer.wait_time = randf_range(0.5, 5.5)
	pitch_shift_timer.start()
