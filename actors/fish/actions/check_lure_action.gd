extends ActionLeaf

# This action checks to ensure there are still lures detected by the fish.
func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("lure_objects").size() == 0:
		return FAILURE
	else:
		return SUCCESS

