extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		lure.player_ref._goto("idle") # TODO: should be an "item_get" state
	
	actor.queue_free()
	return SUCCESS
