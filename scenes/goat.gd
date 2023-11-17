class_name Goat
extends CharacterBody2D

# exported parameters
@export_range(1, 2, 1) var player: int = 2
@export_range(0, 1) var jump_lean: float = 0.8 # increase to make jumps less vertical & more perpendicular to floor
@export var jump_vel: float = -750.0
@export var run_acc: float = 30.0
@export var run_dec: float = 40.0
@export var max_hor_vel: float = 700.0

# constants
const MIN_ANIMATED_RUN_SPEED: float = 2.0 # speed below which we do not animate

# child nodes
@onready var sprite: AnimatedSprite2D = $sprite as AnimatedSprite2D
@onready var floor_test: ShapeCast2D = $floor_test as ShapeCast2D

# get gravity from project settings to sync with RigidBody nodes
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func find_ground():
	# scan down to find first colliding object in "ground" group;
	# return whether ground is found & normal vector
	for index in range(floor_test.get_collision_count()):
		if floor_test.get_collider(index).is_in_group("ground"):
			return [true, floor_test.collision_result[index].normal]
	return [false, Vector2(0, -1)]

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	
	if not on_floor:
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("p%d_up" % player) and on_floor:
		velocity.y = jump_vel

	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	if direction:
		if sign(velocity.x) != sign(direction):
			velocity.x = move_toward(velocity.x, direction * max_hor_vel, run_dec)
		else:
			velocity.x = move_toward(velocity.x, direction * max_hor_vel, run_acc)
	else:
		velocity.x = move_toward(velocity.x, 0, run_dec)
		
	move_and_slide()

func _process(_delta: float) -> void:
	# animate sprite based on current movement direction
	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	if direction != 0: sprite.flip_h = direction > 0
	if velocity.length() > MIN_ANIMATED_RUN_SPEED:
		sprite.play()
	else:
		sprite.stop()
