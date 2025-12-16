extends Node2D

var place_holder_item_scene = preload("res://objects/fish_types/clown_fish/clown_fish.tscn")
var recent_manual_drop = false
var item_data_ref = null

@onready var host_sprite

var drop_height = 25
var starts_at_top = false

const TWEEN_DURATION = 0.1
const RECOVERY_FACTOR = 0.52

func set_item_data(item_data):
	item_data_ref = item_data

func _ready() -> void:
	if item_data_ref == null:
		item_data_ref = { # fake data
			"scene": place_holder_item_scene,
			"name": "Test Clown Fish",
			"weight": 55.55,
			"item_type": RefData.item_types.FISH,
		}
		
	var item = item_data_ref.scene.instantiate()
	host_sprite = item.get_node("%AnimatedSprite2D") # maybe check for Srpite2D as well
	#item.global_position = self.global_position
	add_child(item)
	start_bounce_tween()

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

func start_bounce_tween():
	if starts_at_top:
		await drop_down(drop_height).finished
	
	var bounce_height = drop_height * RECOVERY_FACTOR
	
	while bounce_height > 1:
		await bounce_up(bounce_height).finished
		await drop_down(drop_height).finished
		bounce_height = bounce_height * RECOVERY_FACTOR
	
func bounce_up(height) -> Tween:
	var y_end = -height
	var tween = create_tween()
	tween.tween_property(host_sprite, "position:y", y_end, TWEEN_DURATION)
	tween.set_ease(Tween.EASE_OUT)
	tween.play()
	return tween

func drop_down(height) -> Tween:
	#var y_start = -height
	var tween = create_tween()
	tween.tween_property(host_sprite, "position:y", 0, TWEEN_DURATION)
	tween.set_ease(Tween.EASE_IN)
	tween.play()
	return tween
