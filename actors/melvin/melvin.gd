extends Node2D

#TODO: Clean up list of items. Rich text edits for coloring based on item type.
#TODO (cont.) Next dialog page if list is > 5 items.
#TODO (cont.) Add ", and" for last item.
#TODO (cont.) Consolodate and add number of items so it's not hard coded to 1x value
#TODO (cont.) Combine value items ex. 48x Boilies

@export var item_drops_sales_area: Area2D

var player_ref = null

func _ready() -> void:
	player_ref = self.get_parent().get_node("%Player")

func get_items_to_sell() -> Array[Node2D]:
	var items_to_sell: Array[Node2D] = []
	var areas = item_drops_sales_area.get_overlapping_areas()
	
	for area: Area2D in areas:
		if area.is_in_group("item_drop"):
			var item_drop = area.get_parent()
			#var item_data = item_drop.item_data_ref
			items_to_sell.push_back(item_drop)
	
	return items_to_sell

func get_item_names(item_list: Array[Node2D]) -> Array[String]:
	var item_names: Array[String] = []
	
	for item: Node2D in item_list:
		item_names.push_back(item.item_data_ref.name)
		
	return item_names

func determine_sell_prices(item_list: Array[Node2D]):
	var total_sell_price = 0
	
	for item: Node2D in item_list:
		var sell_price = 0
		
		if item.item_data_ref.has("value"):
			sell_price = item.item_data_ref.value * item.item_data_ref.sell_price
		else:
			sell_price = item.item_data_ref.sell_price
		
		total_sell_price += sell_price
	
	return total_sell_price

func interact():
	if not player_ref.interacting:
		var items_to_sell = get_items_to_sell()
		player_ref.interacting = true
		player_ref.anim.play("idle_west")
		player_ref.show_shells()
		
		if items_to_sell.size() > 0:
			var item_names = get_item_names(items_to_sell)
			var total_sell_price = determine_sell_prices(items_to_sell)
			var sell_dialog1 = "Oh! You got some items to sell. Let's see here..."
			var sell_dialog2 = "Looks like you got: 1x "
			sell_dialog2 += ", 1x ".join(item_names)
			sell_dialog2 += " to sell."
			var sell_dialog3 = "The total comes to [color=green]%s shells[/color]. Does that work for you?" % [total_sell_price]
			var sell_dialogs: Array[String] = [sell_dialog1, sell_dialog2, sell_dialog3]
			await player_ref.custom_dialog(sell_dialogs)
			var yes = await player_ref.yes_no_dialog()
			
			if yes:
				print("Gain %s shells." % [total_sell_price])
				Globals.shells += total_sell_price
				for item in items_to_sell:
					item.queue_free()
				var yes_dialog: Array[String] = ["Thank you sir! Pleasure doing business with you. Come back anytime!"]
				await player_ref.custom_dialog(yes_dialog)
			else:
				var no_dialog: Array[String] = ["No problem. Come back and see me if ya change yer mind!"]
				await player_ref.custom_dialog(no_dialog)

			player_ref.reset_dialog_ui()
		else:
			var dialog1 = "Hey there, thanks for coming into my shop. Check out the back of the store to see my wares."
			var dialog2 = "If you're looking to sell, drop your items on the carpet and I'll get you a tally of the total sales price."
			var dialogs: Array[String] = [dialog1, dialog2]
			await player_ref.custom_dialog(dialogs)
			player_ref.reset_dialog_ui()
			
		player_ref.hide_shells()
		# Await .1 seconds before setting interacting to false so we don't get stuck in an interaction loop.
		await get_tree().create_timer(0.1, false, false, true).timeout
		player_ref.interacting = false
	
