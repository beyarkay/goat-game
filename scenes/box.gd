class_name Box
extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $sprite as AnimatedSprite2D
@onready var break_sound: AudioStreamPlayer2D = $break_sound as AudioStreamPlayer2D

func hit(_damage: float) -> void:
	sprite.play()
	break_sound.play()
	await sprite.animation_finished
	queue_free()
