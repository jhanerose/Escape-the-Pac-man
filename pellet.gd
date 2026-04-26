extends Area2D

@export var points = 10

func _ready():
	body_entered.connect(_on_body_entered)
	print("Pellet spawned")

# Pellet.gd
func _on_body_entered(body):
	
	if body.is_in_group("player"):
		print("pellet collected")
		GameManager.add_pellet() # Stored in the Autoload, safe from reloads
		queue_free()
