extends CharacterBody2D


@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer
@onready var chase_player: AudioStreamPlayer2D = $ChasePlayer
@onready var death_player: AudioStreamPlayer2D = $DeathPlayer

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var target_to_chase: CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var nudge_remaining = 0.0
var nudge_dir = Vector2.ZERO
var start_position: Vector2
# --- NEW STUCK LOGIC ---
var last_pos = Vector2.ZERO
var stuck_time = 0.0
@export var teleport_threshold = 1.0 # Seconds before teleporting
@export var teleport_distance = 32.0 # Pixels to jump forward (2 tiles)
var is_waiting = false
#walking and chase speed 
@export var walk_speed = 80.0
@export var chase_speed = 180.0
@export var vision_angle = 0.7  # 1.0 is a laser, 0.0 is 180 degrees, -1.0 is 360 degrees
var current_speed = 80.0
@onready var ray_cast: RayCast2D = $RayCast2D

var is_chasing_music = false

const SPEED = 80.0



func _ready() -> void:
	set_physics_process(false)
	call_deferred("wait_for_physics")
	bgm_player.play()
	chase_player.play()
	chase_player.volume_db = -80 # Start silent
	start_position = global_position
	
func reset_position():
	# 1. Move back to start
	global_position = start_position
	velocity = Vector2.ZERO
	
	# 2. Re-enable the brain
	set_physics_process(true)
	
	# 3. REBOOT THE NAVIGATION (Crucial Step)
	navigation_agent.target_position = global_position # Clear old target
	is_waiting = false
	stuck_time = 0.0
	
	# 4. Reset Music/State
	
	var tween = create_tween() 
	
	# 2. Force volumes back to default immediately (bypassing transitions)
	bgm_player.volume_db = 0
	chase_player.volume_db = -80
	
	# 3. Ensure they are actually playing (in case they stopped)
	if not bgm_player.playing: bgm_player.play()
	if not chase_player.playing: chase_player.play()
	
	# 4. Reset the tracking variable
	is_chasing_music = false 
	update_music(false)
	# 5. Small delay to let the Navigation map sync
	# This prevents the AI from being "stuck" for a frame
	await get_tree().physics_frame
	
	# Pick a new spot to go or start chasing the player again
	if target_to_chase and not target_to_chase.is_hidden:
		navigation_agent.target_position = target_to_chase.global_position
	else:
		navigation_agent.target_position = _get_random_roam_pos()
		
	print("AI Brain fully rebooted and navigation cleared.")
	
func update_music(is_chasing: bool):
	if is_chasing == is_chasing_music: return
	is_chasing_music = is_chasing
	
	var tween = create_tween().set_parallel(true)
	if is_chasing:
		tween.tween_property(bgm_player, "volume_db", -80, 1.0) # Fade out BGM
		tween.tween_property(chase_player, "volume_db", 0, 1.0)  # Fade in Chase
	else:
		tween.tween_property(bgm_player, "volume_db", 0, 1.0)   # Fade in BGM
		tween.tween_property(chase_player, "volume_db", -80, 1.0) # Fade out Chase
		
func wait_for_physics():
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(_delta: float) -> void:
	if not target_to_chase: return
	
	var distance_moved = global_position.distance_to(last_pos)
	
	# --- VISION CONE + RAYCAST LOGIC ---
	var dir_to_player = global_position.direction_to(target_to_chase.global_position)
	var looking_dir = velocity.normalized() if velocity.length() > 0 else Vector2.RIGHT
	var can_see_player = false
	var dot = looking_dir.dot(dir_to_player)
	
	
	# --- HIDING & SEARCH LOGIC ---
	if target_to_chase.is_hidden:
		update_music(false)
		if navigation_agent.is_navigation_finished() and not is_waiting:
			# Just reached the closet/last spot! Start staring.
			is_waiting = true
			velocity = Vector2.ZERO
			$SearchTimer.start()
			print("AI is searching the area...")
		
		# If timer finished, pick a new spot to walk away to
		if navigation_agent.is_navigation_finished() and is_waiting and $SearchTimer.is_stopped():
			navigation_agent.target_position = _get_random_roam_pos()
			is_waiting = false # Reset so it can move to the roam target
			
		current_speed = walk_speed
		
	else:
		# NORMAL CHASE
		is_waiting = false
		if $SearchTimer: $SearchTimer.stop()
		navigation_agent.target_position = target_to_chase.global_position
		
		# 1. Reset sight each frame
		can_see_player = false 
		
		# 2. Check if player is in the cone
		if dot > vision_angle:
			# 3. Check for walls using RayCast
			ray_cast.target_position = ray_cast.to_local(target_to_chase.global_position)
			ray_cast.force_raycast_update()
		
			if ray_cast.is_colliding():
				var collider = ray_cast.get_collider()
				# ONLY set can_see_player to true if the ray hits the player
				if collider == target_to_chase:
					can_see_player = true
		
		# 4. SET SPEED BASED ON THE RAYCAST RESULT
		if can_see_player:
			current_speed = chase_speed
			update_music(true) # Trigger Chase Music
		else:
			current_speed = walk_speed
			update_music(false) # Return to BGM

	# Stop movement if we are waiting/staring
	if is_waiting and not $SearchTimer.is_stopped():
		velocity = Vector2.ZERO
		return

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	# --- REST OF YOUR ORIGINAL PATHFINDING & NUDGE LOGIC ---
	var next_path_pos = navigation_agent.get_next_path_position()
	var raw_dir = global_position.direction_to(next_path_pos)
	var diff = next_path_pos - global_position
	var final_dir = Vector2.ZERO
	var threshold = 0.4
	var move_vec = Vector2.ZERO
	if distance_moved < 0.5:
		stuck_time += _delta
	else:
		stuck_time = 0.0
	
	last_pos = global_position

	if stuck_time > teleport_threshold:
		var jump_dir = global_position.direction_to(navigation_agent.target_position)
		global_position += jump_dir * teleport_distance
		stuck_time = 0.0
		return 

	if nudge_remaining > 0:
		final_dir = nudge_dir
		nudge_remaining -= SPEED * _delta 
	else:
		# Reset move_vec as a Vector2 every frame
		
		
		# Build the vector based on thresholds
		if abs(diff.x) > threshold * abs(diff.y):
			move_vec.x = sign(diff.x)
		if abs(diff.y) > threshold * abs(diff.x):
			move_vec.y = sign(diff.y)
		
		# Correctly normalize the vector
		if move_vec != Vector2.ZERO:
			final_dir = move_vec.normalized()
		else:
			final_dir = Vector2.ZERO
		
		# Nudge logic
		if move_and_collide(final_dir * 8, true):
			nudge_remaining = 16.0 
			if final_dir.x != 0:
				nudge_dir = Vector2(0, sign(raw_dir.y) if raw_dir.y != 0 else 1)
			else:
				nudge_dir = Vector2(sign(raw_dir.x) if raw_dir.x != 0 else 1, 0)
			final_dir = nudge_dir

	velocity = final_dir * current_speed
	move_and_slide()
	update_animation() # Add this line here
	
	
	
# Add this helper function at the bottom of the script
func _get_random_roam_pos() -> Vector2:
	# This picks a point 400-700 pixels away in a random direction
	var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	return global_position + (random_dir * randf_range(400, 700))
	

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# ONLY kill the player if they aren't hidden!
		if not target_to_chase.is_hidden and not body.is_dead:
			set_physics_process(false) 
			velocity = Vector2.ZERO
			body.die() 
			
			print("Caught!")
			$gore.play()
			$Crunch.play()
			$DeathPlayer.play() 
			await $DeathPlayer.finished
			GameManager.lose_life()
		else:
			print("Player is in closet, AI missed!")
			
func update_animation():
	if velocity.length() == 0:
		sprite.stop()
		return

	var angle = velocity.angle() # Returns radians
	var angle_deg = rad_to_deg(angle)
	
	sprite.flip_h = false # Reset flip

	# 8-Directional Check
	if angle_deg > -22.5 and angle_deg <= 22.5:
		sprite.play("walk_right")
	elif angle_deg > 22.5 and angle_deg <= 67.5:
		sprite.play("walk_right") # Or "walk_down" if you only have 4
	elif angle_deg > 67.5 and angle_deg <= 112.5:
		sprite.play("walk_down")
	elif angle_deg > 112.5 and angle_deg <= 157.5:
		sprite.play("walk_down")
		sprite.flip_h = true # Mirror for Down-Left
	elif angle_deg > 157.5 or angle_deg <= -157.5:
		sprite.play("walk_right")
		sprite.flip_h = true # Mirror for Left
	elif angle_deg > -157.5 and angle_deg <= -112.5:
		sprite.play("walk_right")
		sprite.flip_h = true # Mirror for Up-Left
	elif angle_deg > -112.5 and angle_deg <= -67.5:
		sprite.play("walk_up")
	elif angle_deg > -67.5 and angle_deg <= -22.5:
		sprite.play("walk_up")
