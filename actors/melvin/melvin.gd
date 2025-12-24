extends Node2D

@export var item_drops_sales_area: Area2D

var player_ref = null

func _ready() -> void:
	player_ref = self.get_parent().get_node("%Player")

func get_items_to_sell():
	var items_to_sell = []
	var areas = item_drops_sales_area.get_overlapping_areas()
	
	for area: Area2D in areas:
		if area.is_in_group("item_drop"):
			var item_drop = area.get_parent()
			var item_data = item_drop.item_data_ref
			items_to_sell.push_back(item_data)
	
	return items_to_sell

func interact():
	if not player_ref.interacting:
		var items_to_sell = get_items_to_sell()
		player_ref.interacting = true
		player_ref.anim.play("idle_west")
		
		if items_to_sell.size() > 0:
			var sell_dialog1 = "Oh! You got some items to sell. Let's see here..."
			var sell_dialogs: Array[String] = [sell_dialog1]
			await player_ref.custom_dialog(sell_dialogs)
		else:
			var dialog1 = "Hey there, thanks for coming into my shop. Check out the back of the store to see my wares."
			var dialog2 = "If you're looking to sell, drop your items on the carpet and I'll get you a tally of the total sales priice."
			var dialogs: Array[String] = [dialog1, dialog2]
			await player_ref.custom_dialog(dialogs)
			
		# Await .1 seconds before setting interacting to false so we don't get stuck in an interaction loop.
		await get_tree().create_timer(0.1, false, false, true).timeout
		player_ref.interacting = false
	
