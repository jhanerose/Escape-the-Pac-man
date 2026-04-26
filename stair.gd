extends Area2D

var is_active: bool = false # Starts inactive

func _ready():
	body_entered.connect(_on_body_entered)
	# Connect to the GameManager signal to "turn on" the stairs
	GameManager.all_pellets_collected.connect(_on_activate_stair)
	
	# Ensure it starts hidden and non-collidable
	hide()
	monitoring = false 

func _on_activate_stair():
	show()
	monitoring = true # Now it can detect the player
	is_active = true
	print("Stairs are now active!")

func _on_body_entered(body: Node2D):
	# Only trigger if the player enters AND the stairs are active
	if is_active and body.is_in_group("player"):
		get_tree().change_scene_to_file("res://Win.tscn")
