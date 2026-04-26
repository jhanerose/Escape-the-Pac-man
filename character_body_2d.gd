extends CharacterBody2D

const speed = 100
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D
@onready var player = $"../CharacterBody2D"
var last_known_position: Vector2
var search_timer = 3.0

enum State {
	IDLE,
	CHASE,
	SEARCH,
	PATROL
}

var current_state = State.IDLE

func _physics_process(_delta):

	match current_state:
		
		State.CHASE:
			if player.is_hidden:
				current_state = State.SEARCH
			else:
				chase_player()
				
		State.SEARCH:
			search_last_position()
			
		State.PATROL:
			patrol()
	




func chase_player():
	last_known_position = player.global_position
	navigation_agent.target_position = last_known_position
	var next_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	velocity = direction * speed
	
	move_and_slide()


func patrol():
	var random_pos = Vector2(
		randf_range(0, 1000),
		randf_range(0, 1000)
	)
	
	navigation_agent.target_position = random_pos
	current_state = State.IDLE


func search_last_position():
	navigation_agent.target_position = last_known_position
	
	var next_pos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(next_pos)
	velocity = direction * speed
	move_and_slide()
	
	if global_position.distance_to(last_known_position) < 5:
		current_state = State.PATROL


#make path
func makepath() -> void:
	navigation_agent.target_position = player.global_position



func _on_timer_timeout():
	makepath()
