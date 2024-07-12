extends ActionLeaf

@export var rotation_speed = 3

# This action rotates actor towards target pos (new pos) over time.
func tick(actor: Node, blackboard: Blackboard) -> int:
	var target_rotation = get_angle_between_positions(actor.position, blackboard.get_value("new_pos"))
	var delta = get_physics_process_delta_time()
	
	# Calculate the shortest path to the target rotation
	var shortest_angle = angle_difference(actor.rotation, target_rotation)

	# Calculate the amount to rotate this frame
	var angle_step = rotation_speed * delta

	# If the angle to rotate is smaller than the step, set the final rotation
	if abs(shortest_angle) <= angle_step:
		actor.rotation = target_rotation
		return SUCCESS
	else:
		# Otherwise, rotate in the direction of the target
		actor.rotation += angle_step * sign(shortest_angle)
		return RUNNING

func get_angle_between_positions(p1: Vector2, p2: Vector2) -> float:
	var dx = p2.x - p1.x
	var dy = p2.y - p1.y
	return atan2(dy, dx)
