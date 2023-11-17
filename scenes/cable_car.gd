extends Node

var duration_ms: int = 5
var progress = 0.0
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var from: Marker2D = $from
@onready var to: Marker2D = $to
var looping_progress = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    progress += delta / duration_ms
    while progress > 1.0:
        progress -= 1.0
    looping_progress = 1 - abs(progress * 2 - 1)
    static_body.position = from.position + (to.position - from.position) * looping_progress
