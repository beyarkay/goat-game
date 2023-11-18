class_name Plank
extends RigidBody2D

@onready var wobbler: AnimationPlayer = $wobbler as AnimationPlayer
@onready var despawn_timer: Timer = $despawn_timer as Timer
@onready var wobble_sound: AudioStreamPlayer2D = $wobble_sound as AudioStreamPlayer2D
@onready var fall_sound: AudioStreamPlayer2D = $fall_sound as AudioStreamPlayer2D

const TOTAL_WOBBLES = 7

var wobbles := 0

func fall() -> void:
	gravity_scale = 1
	lock_rotation = false
	freeze = false
	angular_velocity = randf_range(-10, 10)
	fall_sound.play()
	despawn_timer.start()

func begin_fall() -> void:
	wobbler.play("wobble")
	play_wobble_sound()

func play_wobble_sound() -> void:
	wobble_sound.pitch_scale = randf_range(0.7, 1.4)
	wobble_sound.play()

func _ready() -> void:
	gravity_scale = 0
	lock_rotation = true
	freeze = true

func _on_wobbler_animation_finished(_anim_name: StringName) -> void:
	wobbles += 1
	if wobbles == TOTAL_WOBBLES:
		fall()
	else:
		wobbler.play()

func _on_despawn_timer_timeout() -> void:
	queue_free()

func _on_audio_stream_player_2d_finished() -> void:
	if wobbler.is_playing():
		play_wobble_sound()
