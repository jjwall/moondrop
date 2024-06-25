extends ActionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var tween = create_tween()
	tween.tween_property(actor, "modulate:a", 0, 0.5)
	tween.tween_callback(on_fade_out.bind(actor))
	tween.play()
	return RUNNING

func on_fade_out(actor: Node):
	actor.queue_free()
	return SUCCESS
