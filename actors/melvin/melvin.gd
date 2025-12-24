extends Node2D

var player_ref = null

func _ready() -> void:
	player_ref = self.get_parent().get_node("%Player")

func interact():
	# If no items... blah
	if not player_ref.interacting:
		#interacting = true
		var dialog1 = "Hey there, thanks for coming into my shop. Check out the back of the store to see my wares."
		var dialog2 = "If you're looking to sell, drop your items on the carpet and I'll get you a tally of the total sales priice."
		var dialogs: Array[String] = [dialog1, dialog2]
		
		player_ref.interacting = true
		player_ref.anim.play("idle_west")
		await player_ref.custom_dialog(dialogs)
		# Await .1 seconds before setting interacting to false so we don't get stuck in an interaction loop.
		await get_tree().create_timer(0.1, false, false, true).timeout
		player_ref.interacting = false
