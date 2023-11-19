class_name Bridge
extends Path2D

@export var plank_scene: PackedScene
@export var bottom_line_shift: Vector2
@export_range(1, 10, 1) var num_planks: int

@onready var follow: PathFollow2D = $follow as PathFollow2D
@onready var crumble_timer: Timer = $crumble_timer as Timer

@onready var top_line: Line2D = $top_line as Line2D
@onready var bottom_line: Line2D = $bottom_line as Line2D

const MIN_CRUMBLE_TIME = 7.0
const MAX_CRUMBLE_TIME = 15.0

var planks: Array[Plank] = []

func reset_crumble_timer() -> void:
	crumble_timer.wait_time = randf_range(MIN_CRUMBLE_TIME, MAX_CRUMBLE_TIME)
	crumble_timer.start()

func _ready() -> void:
	for i in range(num_planks):
		follow.progress_ratio = float(i + 1) / (num_planks + 1) + randf_range(-0.01, 0.01)
		var plank = plank_scene.instantiate()
		plank.position = follow.position + Vector2.DOWN.rotated(follow.rotation) * 20.0
		plank.rotation = follow.rotation + randf_range(-PI / 25, PI / 25)
		plank.scale.x = randf_range(0.95, 1.15)
		planks.append(plank)
		add_child(plank)

	top_line.points = curve.get_baked_points()
	bottom_line.points = curve.get_baked_points()
	bottom_line.scale.x = 1.1
	bottom_line.position += bottom_line_shift

	reset_crumble_timer()

func _on_crumble_timer_timeout() -> void:
	if planks.size() == 0:
		return
	var plank_to_fall := randi_range(0, planks.size() - 1)
	planks[plank_to_fall].begin_fall()
	planks.remove_at(plank_to_fall)
	reset_crumble_timer()
