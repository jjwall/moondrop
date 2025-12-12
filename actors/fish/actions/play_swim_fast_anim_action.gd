extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.play_swim_fast_anim()
	return SUCCESS
