extends Node2D

@onready var player = %Player

var basic_rod_scene = preload("res://objects/rod_types/basic_rod/basic_rod.tscn")

func _ready() -> void:
	var basic_rod_item_data = {
		"name": "Basic Rod",
		"description": "A simple rod that will catch you all of your basic fish.",
		"item_type": RefData.item_types.ROD,
		"scene": basic_rod_scene
	}
	
	player.drop_item(basic_rod_item_data, true)
