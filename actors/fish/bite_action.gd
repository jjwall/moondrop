extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.queue_free()
	return SUCCESS
	#if blackboard.get_value("detected_lure", null) == null:
		#return FAILURE
	#else:
		#var lure = blackboard.get_value("detected_lure", null)
	