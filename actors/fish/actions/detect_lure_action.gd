extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	#print(blackboard.get_value("lure_objects").size())
	if blackboard.get_value("lure_objects").size() > 0:
		if blackboard.get_value("detected_lure", null) == null:
			var detected_lure = blackboard.get_value("lure_objects").pick_random()
			if !detected_lure.fish_interested:
				detected_lure.fish_interested = true
				blackboard.set_value("detected_lure", detected_lure)
				blackboard.set_value("new_pos", detected_lure.global_position)
				# TODO: set new_angle too?
				return SUCCESS
			else:
				return FAILURE
		return SUCCESS
	else:
		blackboard.set_value("detected_lure", null)
		return FAILURE
