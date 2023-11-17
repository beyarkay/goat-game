class_name Goat
extends CharacterBody2D

@export var player: int = 2

const MAX_SPEED: float = 300.0
const ACCELERATION: float = 30.0
const JUMP_VELOCITY: float = -400.0

# get gravity from project settings to sync with RigidBody nodes
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("p%d_up" % player) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	if direction:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

	move_and_slide()

func _process(delta: float) -> void:
	if velocity.x != 0: $AnimatedSprite2D.flip_h = velocity.x > 0
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
