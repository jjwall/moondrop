extends Node2D
var basic_rod_scene = preload("res://objects/rod_types/basic_rod/basic_rod.tscn")
var boilies_scene = preload("res://objects/bait_types/boilies/boilies.tscn")
var test_clown_fish_scene = preload("res://objects/fish_types/clown_fish/clown_fish.tscn")

#@onready var camera_shake: CameraShake = $Player/Camera2D/CameraShake
var fish_group: Node2D
@onready var player = %Player

func _ready() -> void:
	fish_group = $FishGroup
	
	match Globals.recent_exit_location:
		Globals.ExitLocations.GAME_START:
			var basic_rod_item_data = {
				"name": "Basic Rod",
				"description": "A simple rod that will catch you all of your basic fish.",
				"item_type": RefData.item_types.ROD,
				"scene": basic_rod_scene,
				"buy_price": 250,
				"sell_price": 1000,
			}
		
			player.drop_item(basic_rod_item_data, true)
		
			var boilies_item_data = {
				"name": "Boilies",
				"description": "An artificial fishing bait made from boiled paste primarily consisting of flours and cornmeals. It's good for your basic fish.",
				"value": 50,
				"max_value": 50,
				"item_type": RefData.item_types.BAIT,
				"scene": boilies_scene,
				"buy_price": 2,
				"sell_price": 1,
			}
		
			player.drop_item(boilies_item_data, true)
			
		Globals.ExitLocations.SHOP_EXIT:
			player.position = $ShopExitMarker2D.position
	
	#var boilies_item_data2 = {
		#"name": "Boilies",
		#"description": "An artificial fishing bait made from boiled paste primarily consisting of flours and cornmeals. It's good for your basic fish.",
		#"value": 48,
		#"max_value": 50,
		#"item_type": RefData.item_types.BAIT,
		#"scene": boilies_scene
	#}
	#
	#player.drop_item(boilies_item_data2, true)
	#
	#var boilies_item_data3 = {
		#"name": "Boilies",
		#"description": "An artificial fishing bait made from boiled paste primarily consisting of flours and cornmeals. It's good for your basic fish.",
		#"value": 2,
		#"max_value": 50,
		#"item_type": RefData.item_types.BAIT,
		#"scene": boilies_scene
	#}
	#
	#player.drop_item(boilies_item_data3, true)
	
	# Generate a bunch of caught fish for inventory testing.
	#for i in range(15):
		#var item_data_ref = { # fake data
			#"scene": test_clown_fish_scene,
			#"name": "Test Clown Fish",
			#"weight": 55.55,
			#"item_type": RefData.item_types.FISH,
		#}
		#
		#player.drop_item(item_data_ref, true)

# Called in the fish_spawn_area.gd script
func add_fish_to_group(fish: Node2D):
	fish_group.call_deferred("add_child", fish)

#func _on_bouncing_character_body_2d_bounce(collision: KinematicCollision2D) -> void:
	##camera_shake.apply_impulse(Vector2.from_angle(randf_range(0, TAU)) * 2000)
	#camera_shake.rumble(50, 0.25)
