extends ActionLeaf

@export var move_speed = 75

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_pos = blackboard.get_value("new_pos")
	var delta = get_physics_process_delta_time()
	
	# Calculate the direction to the target position
	var direction = (target_pos - actor.position).normalized()
	var distance_to_target = actor.position.distance_to(target_pos)
	actor.velocity = (move_speed * direction) * distance_to_target/10

	# Calculate the distance to move this frame
	var distance_to_move = move_speed * delta
	
	# Calculate the new position
	var new_position = actor.position + direction * distance_to_move

	# If the distance to the target is less than the step, set the final position
	if distance_to_target <= distance_to_move:
		#actor.move_and_slide()
		#actor.position = target_pos
		return SUCCESS
	else:
		# Otherwise, move towards the target
		#actor.position = new_position
		actor.move_and_slide()
		return RUNNING
