extends ActionLeaf


func tick(_actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		lure.fish_hooked = false
		lure.fish_interested = false
		
	return SUCCESS
