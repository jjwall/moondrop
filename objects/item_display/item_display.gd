extends Node2D

@export var item_display_node: Node2D
@export var item_name: String
@export var item_type: RefData.item_types
@export var value: int = 1
@export var buy_price: int
@export var sell_price: int

var player_ref = null

func _ready() -> void:
	player_ref = self.get_parent().get_node("%Player")

func interact() -> void:
	if not player_ref.interacting:
		player_ref.interacting = true
		player_ref.anim.play("idle_north")
		player_ref.show_shells()
		
		var buy_dialog = "That is a [color=green]%s[/color]. I'm selling it for %s shells. Would you like to purchase it?" % [item_name, buy_price]
		var buy_dialogs: Array[String] = [buy_dialog]
		await player_ref.custom_dialog(buy_dialogs)
		var yes = await player_ref.yes_no_dialog()
		
		if yes: 
			if Globals.shells >= buy_price:
				Globals.shells -= buy_price
				print("successful purchase")
				var confirm_purchase_dialog: Array[String] = ["Thanks for the purchase! I hope this serves you well."]
				await player_ref.custom_dialog(confirm_purchase_dialog)
				# goto get item state
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
