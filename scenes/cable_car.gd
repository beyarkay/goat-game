class_name CableCar
extends Path2D

@export_range(0.5, 1.5) var speed: float = 1.0

@onready var line: Line2D = $line as Line2D
@onready var mover: AnimationPlayer = $PathFollow2D/mover
@onready var rail_sound: AudioStreamPlayer2D = $rail_sound as AudioStreamPlayer2D
@onready var pitch_shift_timer: Timer = $pitch_shift_timer as Timer

func _ready() -> void:
	line.points = curve.get_baked_points()
	mover.speed_scale = speed

func _on_pitch_shift_timer_timeout() -> void:
	rail_sound.pitch_scale = randf_range(0.8, 1.2)
	pitch_shift_timer.wait_time = randf_range(0.5, 5.5)
	pitch_shift_timer.start()
