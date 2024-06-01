extends ActionLeaf

@export var radius: float = 50

func tick(actor, blackboard):
	var new_pos = get_random_pos_within_radius(actor.position.x, actor.position.y, radius)
	var new_angle = get_angle_between_positions(actor.position, new_pos)
	blackboard.set_value("new_pos", new_pos)
	blackboard.set_value("new_angle", new_angle)
	return SUCCESS

func get_random_pos_within_radius(pos_x: float, pos_y: float, radius: float) -> Vector2:
	# Random angle in radians
	var angle = randf() * PI * 2
	# Random distance from the center within the radius
	var distance = randf() * radius
	# Calculate the new x and y positions
	var random_x = pos_x + cos(angle) * distance
	var random_y = pos_y + sin(angle) * distance
	return Vector2(random_x, random_y)

func get_angle_between_positions(p1: Vector2, p2: Vector2) -> float:
	var dx = p2.x - p1.x
	var dy = p2.y - p1.y
	return atan2(dy, dx)
