extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	if is_instance_valid(lure):
		lure.fish_hooked = true
	
	if blackboard.get_value("lure_objects").size() == 0:
		return FAILURE
		
	if lure.fish_successful_catch:
		return SUCCESS
	else:
		return RUNNING
	#actor.queue_free()
	#return RUNNING
	#return SUCCESS
	
	#if blackboard.get_value("detected_lure", null) == null:
		#return FAILURE
	#else:
		#var lure = blackboard.get_value("detected_lure", null)
	
