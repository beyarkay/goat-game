extends Area2D


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		assert(body.has_method("respawn"), "Body " + body.to_string() + " doesn't have .respawn()")
		# Force a respawn of the goat
		body.respawn()
