class_name MainMenu
extends Node

@onready var level_select: OptionButton = %level_select as OptionButton

const levels = [
	"res://levels/misty_mountains.tscn",
	"res://levels/in_the_mines.tscn",
	"res://levels/anthills.tscn"
]

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(levels[level_select.selected])
