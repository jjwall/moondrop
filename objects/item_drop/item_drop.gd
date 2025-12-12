extends Node2D

var place_holder_item_scene = preload("res://objects/fish_types/clown_fish/clown_fish.tscn")
var recent_manual_drop = false
var item_data_ref = null

func set_item_data(item_data):
	item_data_ref = item_data

func _ready() -> void:
	if item_data_ref == null:
		item_data_ref = { # fake data
			"scene": place_holder_item_scene,
			"name": "Test Clown Fish",
			"weight": 55.55,
		}
		
	var item = item_data_ref.scene.instantiate()
	#item.global_position = self.global_position
	add_child(item)
	# TODO: Add dropping animation

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"): # and not recent_manual_drop:
		if not recent_manual_drop:
			var player_ref = get_tree().get_first_node_in_group("player")
			var successful = player_ref.pickup_item(item_data_ref)
			
			if successful:
				# TODO: render pickup animation
				self.queue_free()
		else:
			recent_manual_drop = false
