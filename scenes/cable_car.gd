extends Node

@export var speed: float = 0.005
var progress = 0.0
@onready var static_body: StaticBody2D = $StaticBody2D
@export var from: Marker2D = null
@export var to: Marker2D = null
var looping_progress = 0.0

func _ready() -> void:
    if from == null: from = $from
    if to == null: to = $to

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    progress += delta * speed
    while progress > 1.0:
        progress -= 1.0
    looping_progress = 1 - abs(progress * 2 - 1)
    static_body.position = from.position + (to.position - from.position) * looping_progress
