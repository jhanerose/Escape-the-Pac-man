extends Control

# Replace this with the actual path to your main game scene
@export var game_scene_path : String = "res://Level1.tscn" 

func _on_start_button_pressed() -> void:
	# This loads your game level
	get_tree().change_scene_to_file(game_scene_path)

func _on_exit_button_pressed() -> void:
	# This closes the game application
	get_tree().quit()
