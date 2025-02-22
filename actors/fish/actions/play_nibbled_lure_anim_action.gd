extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		lure.play_nibbled_anim()
		
	return SUCCESS

