extends ActionLeaf

@export var move_speed = 25
@export var acceptance_radius = 50

func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_pos = blackboard.get_value("new_pos")
	var delta = get_physics_process_delta_time()
	
	# Calculate the direction away from the target position
	var direction = (target_pos - actor.position).normalized() * -1
	var distance_to_target = actor.position.distance_to(target_pos)
	actor.velocity = move_speed * direction
	
	if blackboard.get_value("lure_objects").size() == 0:
		return FAILURE

	# Move away from the target
	if distance_to_target < acceptance_radius:
		actor.move_and_slide()
		return RUNNING
	else:
		#actor.velocity = Vector2.ZERO
		return SUCCESS




#func tick(actor: Node, blackboard: Blackboard) -> int:
	#print("hello :D")
	#return SUCCESS





		#if blackboard.get_value("detected_lure", null) == null:
			#var detected_lure = blackboard.get_value("lure_objects").pick_random()
			#blackboard.set_value("detected_lure", detected_lure)
			#blackboard.set_value("new_pos", detected_lure.global_position)
