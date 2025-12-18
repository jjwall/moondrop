extends Node2D

@onready var player = %Player

var basic_rod_scene = preload("res://objects/rod_types/basic_rod/basic_rod.tscn")

func _ready() -> void:
	player.anim.play("idle_north")
	
	var basic_rod_item_data = {
		"name": "Basic Rod",
		"description": "A simple rod that will catch you all of your basic fish.",
		"item_type": RefData.item_types.ROD,
		"scene": basic_rod_scene
	}
	
	player.drop_item(basic_rod_item_data, true)

func interact():
	Globals.recent_exit_location = Globals.ExitLocations.SHOP_EXIT
	SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")
