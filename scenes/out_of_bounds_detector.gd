extends Area2D

func _ready() -> void:
	for body in get_tree().get_nodes_in_group("player"):
		assert(body.has_method("respawn"), "Body " + body.to_string() + " doesn't have .respawn()")

func _physics_process(_delta: float) -> void:
	# Respawn any goats that go out of the level
	for body in get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		body.respawn()
