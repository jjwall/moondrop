extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	print("hello :D")
	return SUCCESS


		#if blackboard.get_value("detected_lure", null) == null:
			#var detected_lure = blackboard.get_value("lure_objects").pick_random()
			#blackboard.set_value("detected_lure", detected_lure)
			#blackboard.set_value("new_pos", detected_lure.global_position)
