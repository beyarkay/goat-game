class_name Plank
extends RigidBody2D

@onready var wobbler: AnimationPlayer = $wobbler as AnimationPlayer

const TOTAL_WOBBLES = 7

var wobbles := 0

func fall() -> void:
	gravity_scale = 1
	lock_rotation = false
	freeze = false
	angular_velocity = randf_range(-10, 10)

func begin_fall() -> void:
	wobbler.play("wobble")

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

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
