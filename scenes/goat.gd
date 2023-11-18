class_name Goat
extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer as AnimationPlayer

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

@export_category("Stats")
var health: float = GlobalState.GOAT_HEALTH_MAX
var is_knocked_out: bool = false
@export var health_regen_duration: float = 8
@onready var health_regen_timeout: Timer = $health_regen_timeout as Timer

signal health_change(player, new_health)
signal shake_screen(strength)

# constants
const MIN_ANIMATED_RUN_SPEED: float = 2.0 # speed below which we do not animate

# child nodes
@onready var sprite: AnimatedSprite2D = $sprite as AnimatedSprite2D
@onready var floor_test: ShapeCast2D = $floor_test as ShapeCast2D

var input_buffer = null

func _ready() -> void:
    input_buffer_timeout.wait_time = input_buffer_duration
    charge_timeout.wait_time = charge_buildup_time
    health_regen_timeout.wait_time = health_regen_duration

func find_ground():
    # scan down to find first colliding object in "ground" group;
    # return whether ground is found & normal vector
    for index in range(floor_test.get_collision_count()):
        if floor_test.get_collider(index).is_in_group("ground"):
            return [true, floor_test.collision_result[index].normal]
    return [false, Vector2(0, -1)]

func _physics_process(delta: float) -> void:
    if is_knocked_out:
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

    # charging attack
    if abs(velocity.x) == charge_vel_threshold && on_floor:
        if charge_timeout.time_left == 0:
            charge_timeout.start()
    else:
        charge_timeout.stop()
        is_charging = false

    move_and_slide()

func _process(_delta: float) -> void:
    # animate sprite based on current movement direction
    if velocity.length() > MIN_ANIMATED_RUN_SPEED:
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
    if (is_charging):
        body.hit(charge_damage)
    if (is_slamming):
        body.hit(slam_damage)

func hit(damage: float) -> void:
    print(self, " has been hit with ", damage, " damage")
    if !is_knocked_out:
        shake_screen.emit(0.5 * damage * (2.0 if health == 0 else 1.0))
        health -= damage
        if health < 0: health = 0
        health_change.emit(player, health)
    else:
        shake_screen.emit(damage * 0.1)
    if health == 0:
        print("knocked out!")
        is_knocked_out = true
        health_regen_timeout.start()


func _on_charge_timeout_timeout() -> void:
    is_charging = true


func _on_health_regen_timeout_timeout():
    health = GlobalState.GOAT_HEALTH_MAX
    health_change.emit(player, health)
    is_knocked_out = false
    print("no longer knocked out")
