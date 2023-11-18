extends Node


func _on_in_the_mines_btn_button_up() -> void:
    get_tree().change_scene_to_file("res://levels/in_the_mines.tscn")


func _on_misty_mountains_btn_button_up() -> void:
    get_tree().change_scene_to_file("res://levels/misty_mountains.tscn")


func _on_anthills_btn_button_up() -> void:
    get_tree().change_scene_to_file("res://levels/anthills.tscn")
