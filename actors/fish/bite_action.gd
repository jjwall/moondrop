extends ActionLeaf

# TODO: implement...
# TODO: Study animal crossing fish behaviors for tracking movement.
func tick(actor: Node, blackboard: Blackboard) -> int:
	print("bite!!!")
	#actor.queue_free()
	return RUNNING
	#return SUCCESS
	
	#if blackboard.get_value("detected_lure", null) == null:
		#return FAILURE
	#else:
		#var lure = blackboard.get_value("detected_lure", null)
	
