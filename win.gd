extends Control

@onready var color_rect = $ColorRect
@onready var game_won = $AudioStreamPlayer2D

func _ready():
	# 1. Setup initial state
	color_rect.color = Color(0, 0, 0, 0) 
	game_won.play()

# 2. Fade in the black background
	var tween = create_tween()

# This tells the Alpha (:a) to move from 0 to 1 over 3 seconds
	print("You Won!!!")
	tween.tween_property(color_rect, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE)
	

	await tween.finished
	await get_tree().create_timer(2.0).timeout
	

	get_tree().change_scene_to_file("res://main_menu.tscn")
