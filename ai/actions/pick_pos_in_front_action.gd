extends ActionLeaf

@export var max_distance: float = 75
@export var min_distance: float = 25

func tick(actor: Node, blackboard: Blackboard) -> int:
	var random_distance = randf_range(75, 125)
	var pos_x = actor.position.x + cos(actor.rotation) * random_distance
	var pos_y = actor.position.y + sin(actor.rotation) * random_distance
	blackboard.set_value("new_pos", Vector2(pos_x, pos_y))
	return SUCCESS
