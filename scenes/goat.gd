class_name Goat
extends RigidBody2D

# exported parameters
@export var player: int = 2
@export_range(0, 1) var jump_lean: float = 0.8 # increase to make jumps less vertical & more perpendicular to floor
@export var jump_vel: float = -750.0
@export var run_acc: float = 30.0
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
	var ground = find_ground()
	
	if not ground[0]:
		linear_velocity.y += gravity * delta

	if Input.is_action_just_pressed("p%d_up" % player) and ground[0]:
		linear_velocity -= jump_vel * (jump_lean * ground[1] + (1 - jump_lean) * Vector2(0, -1))

	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	var along_floor = ground[1].rotated(90)
	if direction:
		linear_velocity += direction * run_acc * along_floor
		if abs(linear_velocity.x) > max_hor_vel:
			linear_velocity.x = sign(linear_velocity.x) * max_hor_vel
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, run_acc)

func _process(delta: float) -> void:
	# animate sprite based on current movement direction
	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	if direction != 0: sprite.flip_h = direction > 0
	if linear_velocity.length() > MIN_ANIMATED_RUN_SPEED:
		sprite.play()
	else:
		sprite.stop()
