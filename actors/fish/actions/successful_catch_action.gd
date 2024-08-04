extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		lure.player_ref._goto("idle") # TODO: should be an "item_get" state
		
		# Add fish type object as a child of the lure.
		var fish_type = actor.fish_type_scene.instantiate()
		lure.add_child(fish_type)
	
	actor.queue_free()
	return SUCCESS
