extends Node2D

@export var item_display_node: Node2D
@export var item_name: String
@export var item_type: RefData.item_types
@export var description: String
@export var max_value: int
@export var value: int = 1
@export var buy_price: int
@export var sell_price: int

var player_ref = null

func _ready() -> void:
	player_ref = self.get_parent().get_node("%Player")

func get_item_data() -> Dictionary:
	var item_data = {
		"scene": load(item_display_node.scene_file_path),
		"name": item_name,
		"item_type": item_type,
		"description": description,
		"buy_price": buy_price,
		"sell_price": sell_price,
	}
	
	if value > 1:
		item_data["value"] = value
		item_data["max_value"] = max_value
	
	return item_data

func interact() -> void:
	if not player_ref.interacting:
		player_ref.interacting = true
		player_ref.anim.play("idle_north")
		player_ref.show_shells()
		
		var item_amount_dialog1 = ""
		var item_amount_dialog2 = ""
		var temp_buy_price = 0
		if value > 1:
			temp_buy_price = buy_price * value
			item_amount_dialog1 = "Those are"
			item_amount_dialog2 = "them"
		else:
			item_amount_dialog1 = "That is"
			item_amount_dialog2 = "it"
			temp_buy_price = buy_price
		
		var buy_dialog = "%s [color=green]%sx %s[/color]. I'm selling %s for [color=green]%s shells[/color]. Would you like to purchase %s?" % [item_amount_dialog1, value, item_name, item_amount_dialog2, temp_buy_price, item_amount_dialog2]
		var buy_dialogs: Array[String] = [buy_dialog]
		await player_ref.custom_dialog(buy_dialogs)
		var yes = await player_ref.yes_no_dialog()
		
		if yes: 
			if Globals.shells >= temp_buy_price:
				Globals.shells -= temp_buy_price
				print("successful purchase")
				var confirm_purchase_dialog: Array[String] = ["Thanks for the purchase! I hope this serves you well."]
				await player_ref.custom_dialog(confirm_purchase_dialog)
				player_ref.recent_acquired_item = get_item_data()
				player_ref._goto("get_item")
				# TODO: if sold out item, show sold out
			else:
				print("not enough money.")
				var not_enough_shells_dialog: Array[String] = ["Looks like your short on shells. Come back when you've saved up enough."]
				player_ref.shells_amount_label.start_shake()
				await player_ref.custom_dialog(not_enough_shells_dialog)
		else:
			var refuse_purchase_dialog: Array[String] = ["Still thinking about it? No problem, take your time."]
			await player_ref.custom_dialog(refuse_purchase_dialog)

		player_ref.reset_dialog_ui()
		player_ref.hide_shells()
		# Await .1 seconds before setting interacting to false so we don't get stuck in an interaction loop.
		await get_tree().create_timer(0.1, false, false, true).timeout
		player_ref.interacting = false
