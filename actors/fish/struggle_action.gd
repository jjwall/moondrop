extends ActionLeaf

var angle = 0
var follow_distance = 35


func tick(actor: Node, blackboard: Blackboard) -> int:
	var delta = get_physics_process_delta_time()
	#var lure = blackboard.get_value("detected_lure")
	# var lure_pos = lure.position
	var lure_pos = blackboard.get_value("new_pos")
	
	#if lure == null:
		#return FAILURE
		
	angle += delta * 4.5
	actor.position = lure_pos + (Vector2.RIGHT).rotated(angle) * follow_distance
	actor.look_at(lure_pos)
	actor.rotation = actor.rotation - PI/2
	return RUNNING
	#else:
		#return FAILURE
