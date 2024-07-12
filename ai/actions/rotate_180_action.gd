extends ActionLeaf

# This action causes the actor to immediately rotate 180 degrees.
func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.rotation = actor.rotation - PI
	return SUCCESS
