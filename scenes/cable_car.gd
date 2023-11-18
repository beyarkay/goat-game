class_name CableCar
extends Path2D

@onready var line: Line2D = $line as Line2D

func _ready() -> void:
	line.points = curve.get_baked_points()
