extends Control

@onready var color_rect = $ColorRect
@onready var game_over_sound = $AudioStreamPlayer2D

func _ready():
	# Start fully transparent
	color_rect.color.a = 0 
	
	# 1. Play the sound
	game_over_sound.play()
	
	# 2. Fade to solid red over 3 seconds
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 3.0).set_trans(Tween.TRANS_SINE)
	
	# 3. Wait for the fade to finish
	await tween.finished
	
	# 4. Stay on the red screen for 2 more seconds so they can read the text
	await get_tree().create_timer(2.0).timeout

	get_tree().change_scene_to_file("res://main_menu.tscn")
