extends ActionLeaf

@export var move_speed = 75
@export var acceptance_radius = 5

# This action moves the actor towards a given target pos (new_pos in Blackboard).
# Note: This action should always be the child of a TimeLimiterDecorator in the event 
# that the actor is unable to meet the acceptance_radius.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_pos = blackboard.get_value("new_pos")
	var delta = get_physics_process_delta_time()
	
	# Calculate the direction to the target position
	var direction = (target_pos - actor.position).normalized()
	var distance_to_target = actor.position.distance_to(target_pos)
	actor.velocity = (move_speed * direction) * distance_to_target/10

	# If the distance to the target is less than the step, set the final position.
	if distance_to_target <= acceptance_radius:
		return SUCCESS
	else:
		# Otherwise, move towards the target
		actor.move_and_slide()
		return RUNNING
