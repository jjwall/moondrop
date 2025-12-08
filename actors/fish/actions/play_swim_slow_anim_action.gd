extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.play_swim_slow_anim()
	return SUCCESS
