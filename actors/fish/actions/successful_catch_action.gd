extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var lure = blackboard.get_value("detected_lure")
	
	if lure:
		# Switch to wait state triggers reel exit state,
		lure.player_ref.goto_wait_state()
		
		# Add fish type object as a child of the lure.
		var fish_type = actor.fish_type_data.scene.instantiate()
		lure.add_child(fish_type)
		
		# Set recent caught fish data.
		lure.player_ref.recent_caught_fish = actor.fish_type_data
	
	actor.queue_free()
	return SUCCESS
