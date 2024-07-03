extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	if lure:
		lure.fish_hooked = true
	
	if blackboard.get_value("lure_objects").size() == 0:
		return FAILURE
		
	if Input.is_action_just_pressed("ui_accept"): #TODO: decouple. This should happen in player script.
		if lure:
			lure.player_ref._goto("reel") #TODO: decouple. This should happen in player script.
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
	
