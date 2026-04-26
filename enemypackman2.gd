extends CharacterBody2D

const SPEED = 100

@export var player: Node2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	makepath()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var dir = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = dir + SPEED
	move_and_slide()
	
func makepath() -> void:
	navigation_agent.target_position = player.global_position
	



func _on_timer_timeout() -> void:
	makepath()
