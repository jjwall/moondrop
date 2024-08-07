extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		# Switch to wait state triggers reel exit state,
		lure.player_ref._goto("wait")
		
		# Add fish type object as a child of the lure.
		var fish_type = actor.fish_type_data.scene.instantiate()
		lure.caught_fish_type_data = actor.fish_type_data
		lure.add_child(fish_type)
	
	actor.queue_free()
	return SUCCESS
