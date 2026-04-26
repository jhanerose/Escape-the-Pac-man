extends CharacterBody2D


const SPEED = 90.0
const stamina_deplete_rate = 40.0 
const stamina_regen = 30.0
const regen_delay = 1.0
const sprint_speed = 120.0
var start_position: Vector2
var stamina: float = 100.0
var regen_timer: float = 0.0

@onready var sprite := $AnimatedSprite2D

var score = 0
var is_hidden: bool = false
@onready var score_label = %ScoreLabel
@onready var Stamina_bar = $"../CanvasLayer/Stamina Bar"
var is_dead = false

func set_hide(value: bool):
	is_hidden = value
	set_collision_layer_value(1, !value) 
	
func not_hidden(value: bool):
	is_hidden = !value
	set_collision_layer_value(1, value)

func die():
	is_dead = true
	sprite.play("dead_player")
	
func _physics_process(_delta: float) -> void:
	
	var current_speed = SPEED
	if is_dead: 
		velocity = Vector2.ZERO
		return # Don't change animation if dead
	
	if is_hidden:
		velocity = Vector2.ZERO
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var is_sprinting = Input.is_action_pressed("ui_select") and stamina > 0 and direction != Vector2.ZERO
	if is_sprinting:
		current_speed = sprint_speed
		stamina -= stamina_deplete_rate * _delta
		regen_timer = regen_delay
	else:
		if regen_timer > 0:
			regen_timer -= _delta
		elif stamina < 100:
			stamina += stamina_regen * _delta
	stamina = clamp(stamina, 0, 100)
	Stamina_bar.value = stamina
	
	if abs(direction.y) < 0.1:
		direction.y = 0
		
	if abs(direction.x) < 0.1:
		direction.x = 0
		
		
	velocity = direction.normalized() * current_speed
	move_and_slide()
	update_animation(direction)
	
func update_animation(dir):
	
	if dir != Vector2.ZERO:
		# Choose animation based on the dominant direction
		if abs(dir.x) > abs(dir.y):
			sprite.play("walk_right")
			sprite.flip_h = dir.x < 0 # Flips the "walk_right" to face left
		else:
			sprite.flip_h = false # Reset flip for vertical animations
			if dir.y > 0:
				sprite.play("walk_down")
			else:
				sprite.play("walk_up")
	else:
		sprite.stop() # Or sprite.stop()
	
	
func add_score(amount):
	score += amount
	if score_label: # Safety check to prevent crashes
		score_label.text = "Score: " + str(score)
	GameManager.add_pellet() # This saves it in your Global script
func _ready() -> void:
	start_position = global_position # Save where the player starts
	$DarkVision.show()
func reset_position():
	global_position = start_position
	velocity = Vector2.ZERO # Stop any movement
	
	# 1. Reset your "is_dead" variable if you have one
	is_dead = false 
	
	# 2. Reset the Sprite or Animation
	# If using AnimatedSprite2D:
	$AnimatedSprite2D.stop() 
	
	# 3. Re-enable processing if you turned it off during death
	set_process(true)
	set_physics_process(true)
	
	# 4. Show the player again if you hid them
	show() 
