extends Area2D

var player_ref: CharacterBody2D = null

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body

func _on_interaction_area_body_exited(body: Node2D) -> void:
	# ONLY clear the reference if the player is NOT currently hidden inside
	if body == player_ref and not body.is_hidden:
		player_ref = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"): 
		if player_ref != null:
			if not player_ref.is_hidden:
				# HIDE PLAYER
				player_ref.is_hidden = true
				player_ref.hide()
				# IMPORTANT: Don't disable process_mode yet, 
				# just disable movement in your PLAYER script instead.
				# If you MUST disable it, do it here:
				player_ref.process_mode = Node.PROCESS_MODE_DISABLED 
				print("Player is hiding")
			else:
				# EXIT CLOSET
				player_ref.is_hidden = false
				player_ref.show()
				player_ref.process_mode = Node.PROCESS_MODE_INHERIT
				print("Player exited")
				
				# Manually check if we should clear ref after exiting
				if not overlaps_body(player_ref):
					player_ref = null
			
			get_viewport().set_input_as_handled()
