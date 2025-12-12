extends Node2D

var place_holder_item_scene = preload("res://objects/fish_types/clown_fish/clown_fish.tscn")
var item_data_ref = null

func set_item_data(item_data):
	item_data_ref = item_data

func _ready() -> void:
	if item_data_ref == null:
		var item = place_holder_item_scene.instantiate()
		#item.global_position = self.global_position
		add_child(item)
	else:
		var item = item_data_ref.scene.instantiate()
		#item.global_position = self.global_position
		add_child(item)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("ran into players")
