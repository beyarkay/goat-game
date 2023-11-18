class_name Box
extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $sprite as AnimatedSprite2D

func hit(_damage: float) -> void:
	sprite.play()
	await sprite.animation_finished
	queue_free()
