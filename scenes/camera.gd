extends Node2D

@onready var camera: Camera2D = $Camera2D

## The inner fraction of the screen that the goats should occupy. The camera
## will zoom in/out so try and ensure that
##    (distance between goats) / (screen size)
## remains constant
@export var screen_fraction = 0.75

@export var zoom_in_step_size = 0.001
@export var zoom_out_step_size = 0.002

## The camera won't zoom in any less than this
@export_range(0.01, 3.0, 0.01) var min_zoom = 1.0
## The camera won't zoom in any more than this
@export_range(0.01, 3.0, 0.01) var max_zoom = 10.0

var players: Array[CharacterBody2D] = []

func _ready() -> void:
    assert(min_zoom <= max_zoom, "Min zoom %f must be <= max zoom %f" % [min_zoom, max_zoom])
    assert(camera != null)
    for node in get_tree().get_nodes_in_group("player"):
        assert(node is CharacterBody2D)
        players.append(node as CharacterBody2D)

func _process(_delta: float) -> void:
    var mean_position = Vector2.ZERO

    var max_dist = 0.0
    # Calculate mean, min, max positions
    for i in range(len(players)):
        mean_position += players[i].position / len(players)

        # Figure out the maximum distance from this player to any other player
        for j in range(len(players)):
            if i <= j: continue
            max_dist = max(max_dist, (players[i].position - players[j].position).length())

    position = mean_position

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
    # print("%.2f %.2f %.2f %.2f" % [target_zoom, camera.zoom.x, target_zoom - camera.zoom.x, zoom_adjustment])
    camera.zoom += Vector2.ONE * zoom_adjustment

