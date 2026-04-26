# GameManager.gd
extends Node

signal life_lost(lives_left)
signal score_updated(new_score)
signal all_pellets_collected

var current_lives: int = 3
var total_pellets_collected: int = 0
var pellets_to_win: int = 1 # Set this to your total pellet count
var announcement_label: Label # Reference to the UI label
var has_won: bool = false # Prevents the announcement from looping
func set_win_threshold(amount: int):
	pellets_to_win = amount
	total_pellets_collected = 0 # Reset count for the new level
	has_won = false

func add_pellet():
	total_pellets_collected += 1
	score_updated.emit(total_pellets_collected)
	
	# Check for win condition
	if total_pellets_collected >= pellets_to_win and not has_won:
		has_won = true
		all_pellets_collected.emit()
		show_announcement("ALL PELLETS COLLECTED! ESCAPE THROUGH THE STAIRS!")
func show_announcement(message: String):
	if announcement_label:
		print("Label found! Showing message.")
		announcement_label.text = message
		announcement_label.visible = true
		
		# Pro "Online Game" look: Fade in and Pulse
		announcement_label.pivot_offset = announcement_label.size / 2
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		announcement_label.scale = Vector2(0.5, 0.5)
		announcement_label.modulate.a = 0
		
		tween.tween_property(announcement_label, "scale", Vector2(1.0, 1.0), 0.5)
		tween.parallel().tween_property(announcement_label, "modulate:a", 1.0, 0.5)
		
		# Auto-hide after 5 seconds
		await get_tree().create_timer(5.0).timeout
		var fade = create_tween()
		fade.tween_property(announcement_label, "modulate:a", 0.0, 1.0)
	else:
		print("CRITICAL: announcement_label is NULL!")
func lose_life():
	current_lives -= 1
	life_lost.emit(current_lives)
	
	if current_lives <= 0:
		game_over()
	else:
		await get_tree().create_timer(1.0).timeout 
		
		# Reset Player
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.reset_position()
			
		# Reset ALL Enemies
		var enemies = get_tree().get_nodes_in_group("enemies")
		print("Found ", enemies.size(), " enemies to reset.") # Debug line
		for enemy in enemies:
			enemy.reset_position()

func game_over():
	print("Game Over!")
	# Reset stats for a fresh game
	current_lives = 3
	total_pellets_collected = 0
	get_tree().change_scene_to_file("res://GameOver.tscn")
