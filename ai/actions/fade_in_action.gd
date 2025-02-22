extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var tween = create_tween()
	tween.tween_property(actor, "modulate:a", 1, 0.5)
	tween.play()
	return SUCCESS
