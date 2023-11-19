class_name Goat
extends CharacterBody2D

# exported parameters
@export_range(1, 2, 1) var player: int = 2

@export_category("Physics")
@export var jump_vel: float = -750.0
@export var run_acc: float = 30.0
@export var run_dec: float = 70.0
@export var max_hor_vel: float = 600
@export var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_category("Inputs")
@export var input_buffer_duration: float = 0.15
@onready var input_buffer_timeout: Timer = $input_buffer_timeout as Timer

@export_category("Charge Attack")
@export var charge_damage: float = 100
@export var charge_vel_threshold: float = max_hor_vel
@export var charge_buildup_time: float = 0.2
@onready var charge_timeout: Timer = $charge_timeout as Timer
var is_charging: bool = false

@export_category("Slam Attack")
@export var slam_damage: float = 150
@export var max_falling_damage: float = 100
@export var slam_gravity_multiplier: float = 1.75
var slamming_dec: float = 10
var is_slamming: bool = false

@export_category("Headbutt Attack")
@export var headbutt_damage: float = 50
# Determines length of time for double tap to trigger headbutt
@export var headbutt_tap_buffer_time: float = 0.2
@export var is_headbutting: bool = false
var headbutt_direction: float = 0
@onready var headbutt_tap_buffer_timeout: Timer = $headbutt_tap_buffer_timeout as Timer
@onready var headbutt_timer: Timer = $headbutt_timer as Timer

@export_category("Stats")
var health: float = GlobalState.GOAT_HEALTH_MAX
var lives: int = GlobalState.GOAT_LIVES_MAX
var is_knocked_out: bool = false
@export var health_regen_duration: float = 8
@onready var health_regen_timeout: Timer = $health_regen_timeout as Timer

signal lives_change(player, new_lives)
signal health_change(player, new_health)
signal shake_screen(strength)

@onready var respawn_immunity_timer: Timer = $respawn_immunity
var has_respawn_immunity = false

# constants
const MIN_ANIMATED_RUN_SPEED: float = 2.0 # speed below which we do not animate

# initialised in _ready()
var SPAWN_POS: Vector2

# child nodes
@onready var sprite: AnimatedSprite2D = $sprite as AnimatedSprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer as AnimationPlayer
@onready var attack_collider: CollisionShape2D = %attack_collider as CollisionShape2D
@onready var goat_sounds: GoatSounds = $goat_sounds as GoatSounds

# sound timers: set up in _ready()
var step_sound_timer: Timer = Timer.new()
var snort_sound_timer: Timer = Timer.new()
var bleat_sound_timer: Timer = Timer.new()

var input_buffer = null

func _ready() -> void:
	input_buffer_timeout.wait_time = input_buffer_duration
	charge_timeout.wait_time = charge_buildup_time
	health_regen_timeout.wait_time = health_regen_duration
	headbutt_tap_buffer_timeout.wait_time = headbutt_tap_buffer_time
	setup_sound_timers()
	
	attack_collider.disabled = true

func setup_sound_timers() -> void:
	# step sounds
	step_sound_timer.wait_time = 0.2
	step_sound_timer.connect("timeout", self._on_step_sound_timer_timeout)
	add_child(step_sound_timer)
	step_sound_timer.start()
	
	# snort sounds
	snort_sound_timer.wait_time = randf_range(1.0, 4.6)
	snort_sound_timer.connect("timeout", self._on_snort_sound_timer_timeout)
	add_child(snort_sound_timer)
	snort_sound_timer.start()
	
	# bleat sounds
	bleat_sound_timer.wait_time = randf_range(2.2, 9.6)
	bleat_sound_timer.connect("timeout", self._on_bleat_sound_timer_timeout)
	add_child(bleat_sound_timer)
	bleat_sound_timer.start()

func _on_step_sound_timer_timeout() -> void:
	# play step sound if on floor
	if is_on_floor() and velocity.length() > MIN_ANIMATED_RUN_SPEED:
		goat_sounds.step()
		step_sound_timer.wait_time = randf_range(0.1, 0.23)
		step_sound_timer.start()

func _on_snort_sound_timer_timeout() -> void:
	# play snorts with increased frequency if running
	goat_sounds.snort()
	if is_charging:
		snort_sound_timer.wait_time = randf_range(0.5, 1.0)
	else:
		snort_sound_timer.wait_time = randf_range(1.0, 4.6)
	snort_sound_timer.start()

func _on_bleat_sound_timer_timeout() -> void:
	goat_sounds.bleat()
	bleat_sound_timer.wait_time = randf_range(2.2, 9.6)
	
func _physics_process(delta: float) -> void:
	if is_knocked_out:
		move_and_slide()
		return

	var on_floor = is_on_floor()

	if not on_floor:
		velocity.y += gravity * delta

	var jumping = Input.is_action_just_pressed("p%d_up" % player)
	if (jumping or input_buffer == "jump") and on_floor:
		velocity.y = jump_vel
	if jumping and not on_floor:
		input_buffer = "jump"

	var direction: float = Input.get_axis("p%d_left" % player, "p%d_right" % player)
	if direction and !is_slamming:
		var acc: float = run_acc
		if sign(velocity.x) != sign(direction): acc = run_dec
		velocity.x = move_toward(velocity.x, direction * max_hor_vel, acc)
	elif is_slamming:
		velocity.x = move_toward(velocity.x, 0, slamming_dec)
	else:
		velocity.x = move_toward(velocity.x, 0, run_dec)

	if direction:
		$attack_area.scale.x = direction
		sprite.flip_h = direction < 0

	# Falling attack
	if Input.is_action_just_pressed("p%d_down" % player) and !on_floor:
		is_slamming = true
		gravity *= slam_gravity_multiplier
		if sprite.flip_h:
			animation.play("slamming_left")
		else:
			animation.play("slamming_right")

	if on_floor:
		is_slamming = false
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
		animation.stop()

	# Charging attack
	if abs(velocity.x) == charge_vel_threshold && on_floor:
		if charge_timeout.time_left == 0:
			charge_timeout.start()
	else:
		charge_timeout.stop()
		is_charging = false
		
	# Headbutt attack
	var input_direction = 0;
	if Input.is_action_just_pressed("p%d_left" % player):
		input_direction = -1
	elif Input.is_action_just_pressed("p%d_right" % player):
		input_direction = 1
	
	if input_direction:
		if input_direction == headbutt_direction && on_floor && headbutt_tap_buffer_timeout.time_left > 0:
			#animation.play("headbutt")
			headbutt_timer.start()
			is_headbutting = true
		else:
			headbutt_tap_buffer_timeout.start()
			headbutt_direction = input_direction
			5
	attack_collider.disabled = not (is_charging or is_headbutting or is_slamming)
	move_and_slide()

func _process(_delta: float) -> void:
	# animate sprite based on current movement direction
	if is_headbutting:
		sprite.play("headbutting")
	elif velocity.length() > MIN_ANIMATED_RUN_SPEED:
		if is_charging:
			sprite.play("charging")
		elif is_slamming:
			sprite.play("slamming")
		else:
			sprite.play("running")
	elif is_knocked_out:
		sprite.play("knocked_out")
	else:
		sprite.play("idle")

func _on_input_buffer_timeout_timeout() -> void:
	input_buffer = null

func _on_area_2d_body_entered(body):
	if (body.is_in_group("player") && body.player == self.player || !body.has_method("hit")):
		return
	if is_charging:
		body.hit(charge_damage)
		goat_sounds.charge_hit()
	if is_slamming:
		body.hit(slam_damage)
	if is_headbutting:
		body.hit(headbutt_damage)

func hit(damage: float) -> void:
	print(self, " has been hit with ", damage, " damage")
	if !is_knocked_out:
		shake_screen.emit(0.5 * damage * (2.0 if health == 0 else 1.0))
		update_health(player, health - damage)
	else:
		shake_screen.emit(damage * 0.1)
	if health == 0:
		is_knocked_out = true
		health_regen_timeout.start()

func _on_charge_timeout_timeout() -> void:
	is_charging = true
	snort_sound_timer.stop()
	_on_snort_sound_timer_timeout()

func update_health(player, new_health):
	health = max(0, new_health)
	health_change.emit(player, health)


func _on_health_regen_timeout_timeout():
	update_health(player, GlobalState.GOAT_HEALTH_MAX)
	is_knocked_out = false
	
func _on_headbutt_tap_buffer_timeout_timeout():
	pass

func _on_headbutt_timer_timeout():
	is_headbutting = false

func respawn() -> void:
	# Sometimes respawn can be called multiple times in quick succession.
	if has_respawn_immunity:
		return
	has_respawn_immunity = true
	respawn_immunity_timer.start()
	lives -= 1
	if lives == 0:
		get_tree().change_scene_to_file("res://levels/main_menu.tscn")
	lives_change.emit(player, lives)
	shake_screen.emit(50)
	update_health(player, GlobalState.GOAT_HEALTH_MAX)
	is_knocked_out = false
	position = SPAWN_POS
	velocity = Vector2.ZERO


func _on_respawn_immunity_timeout() -> void:
	has_respawn_immunity = false
