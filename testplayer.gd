extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var score = 0


func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if abs(direction.y) < 0.1:
		direction.y = 0
		
	if abs(direction.x) < 0.1:
		direction.x = 0
		
		
	velocity = direction.normalized() * SPEED
	move_and_slide()
	
