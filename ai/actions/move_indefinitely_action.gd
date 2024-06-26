extends ActionLeaf

@export var move_speed = 75

# This action causes the actor to move indefinitely in the direction they are already facing.
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.velocity.x = cos(actor.rotation) * move_speed
	actor.velocity.y = sin(actor.rotation) * move_speed
	actor.move_and_slide()
	return RUNNING
