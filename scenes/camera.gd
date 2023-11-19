extends Node2D

@onready var camera: Camera2D = $Camera2D

@export var move_camera = true
@export var zoom_camera = true

## The inner fraction of the screen that the goats should occupy. The camera
## will zoom in/out so try and ensure that
##	(distance between goats) / (screen size)
## remains constant
@export var screen_fraction = 0.65

@export var screen_shake_decay_rate = 0.9

signal shake_screen(strength)

@onready var rand = RandomNumberGenerator.new()
var shake_strength = 0.0

@export var zoom_in_step_size = 0.001
@export var zoom_out_step_size = 0.02

## The camera won't zoom in any less than this
@export_range(0.01, 3.0, 0.01) var min_zoom = 0.55
## The camera won't zoom in any more than this
@export_range(0.01, 3.0, 0.01) var max_zoom = 2.5

var players: Array[CharacterBody2D] = []

func _ready() -> void:
	assert(min_zoom <= max_zoom, "Min zoom %f must be <= max zoom %f" % [min_zoom, max_zoom])
	assert(camera != null)
	for node in get_tree().get_nodes_in_group("player"):
		assert(node is CharacterBody2D)
		players.append(node as CharacterBody2D)

	# Connect up the screen-shake signals
	for player in get_tree().get_nodes_in_group("player"):
		# NOTE: we *cannot* use player.has_signal because it only returns true
		# for signals added via `add_user_signal` ):
		var has_screen_shake_signal = false
		for signal_entry in player.get_signal_list():
			if signal_entry.name == "shake_screen":
				has_screen_shake_signal = true
		assert(
			has_screen_shake_signal,
			"Player " + player.to_string() + " doesn't have screen_shake signal"
			)
		player.shake_screen.connect(_on_shake_screen)


func _process(delta: float) -> void:
	var mean_position = Vector2.ZERO
	var max_dist = 0.0

	if move_camera || zoom_camera:
		# Calculate mean, min, max positions
		for i in range(len(players)):
			mean_position += players[i].position / len(players)

			# Figure out the maximum distance from this player to any other player
			for j in range(len(players)):
				if i <= j: continue
				max_dist = max(max_dist, (players[i].position - players[j].position).length())
	if move_camera:
		position = mean_position

	if zoom_camera:
		var viewport_size = get_viewport().get_visible_rect().size
		var smallest_dimension = min(viewport_size.x, viewport_size.y)

		var target_zoom = clamp(
			screen_fraction / (max_dist / smallest_dimension),
			min_zoom,
			max_zoom
		)

		var zoom_adjustment = clamp(
			target_zoom - camera.zoom.x,
			-zoom_out_step_size,
			zoom_in_step_size,
		)
		camera.zoom += Vector2.ONE * zoom_adjustment

	apply_screen_shake()

func _on_shake_screen(strength) -> void:
	start_screen_shake(strength)

func start_screen_shake(strength):
	shake_strength = strength
	apply_screen_shake()

func apply_screen_shake():
	# Shake the screen
	camera.offset = Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
	# Decay the shake strength
	shake_strength *= screen_shake_decay_rate

