extends Control

@onready var action_to_node = {
	"p1_up": $wasd_indicator/p1_up_sprite,
	"p1_down": $wasd_indicator/HBoxContainer/p1_down_sprite,
	"p1_right": $wasd_indicator/HBoxContainer/p1_right_sprite,
	"p1_left": $wasd_indicator/HBoxContainer/p1_left_sprite,
	"p2_up": $uldr_indicator/p2_up_sprite,
	"p2_down": $uldr_indicator/HBoxContainer/p2_down_sprite,
	"p2_right": $uldr_indicator/HBoxContainer/p2_right_sprite,
	"p2_left": $uldr_indicator/HBoxContainer/p2_left_sprite,
}

func _ready() -> void:
	# A quick assertion to keep our sanity
	for k in action_to_node.keys():
		assert(action_to_node[k] != null, k + " is null")

func _process(_delta: float) -> void:
	for k in action_to_node.keys():
		if Input.is_action_pressed(k):
			action_to_node[k].self_modulate = Color.from_hsv(0, 0, 0.5, 1.0)
		else:
			action_to_node[k].self_modulate = Color.from_hsv(0, 0, 1.0, 1.0)
