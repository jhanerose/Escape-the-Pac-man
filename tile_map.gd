extends TileMapLayer
@export var stair_scene: PackedScene
@export var pellet_scene: PackedScene
@export var max_pellets: int = 50  # Limit to 150 pellets

func _ready():
	# randomize() ensures the "shuffle" is different every time the game starts
	randomize() 
	spawn_pellets()
	GameManager.all_pellets_collected.connect(_on_win_condition)

func _on_win_condition():
	# Find the stair already sitting in the level and show it
	var stair = get_tree().get_first_node_in_group("stairs") # Put your Stair scene in this group
	if stair:
		stair.show()
		# Optionally enable its collision if you disabled it
		# stair.get_node("CollisionShape2D").disabled = false
	
	

		
func spawn_pellets():
	if pellet_scene == null: return 
	
	var player = get_tree().get_first_node_in_group("player")
	var cells = get_used_cells()
	cells.shuffle()

	var created_count = 0
	for cell in cells:
		if created_count >= max_pellets: break
		
		var spawn_pos = map_to_local(cell)
		if player != null:
			if spawn_pos.distance_to(player.global_position) < 200:
				continue 
			
		var pellet = pellet_scene.instantiate()
		pellet.position = spawn_pos
		add_child(pellet)
		created_count += 1 # Track how many we actually put in the world

	# --- ADD THIS LINE ---
	GameManager.set_win_threshold(created_count)
