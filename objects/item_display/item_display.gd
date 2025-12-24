extends Node2D

@export var item_display_node: Node2D
@export var item_name: String
@export var item_type: RefData.item_types
@export var value: int = 1
@export var buy_price: int
@export var sell_price: int

var item_data_ref = null

func interact() -> void:
	print("yo cool item bro")
	print(item_name)

#func _ready() -> void:
	##pass
	#if item_display_node != null:
		#item_data_ref = item_display_node.item_data_ref
		#var item = item_display_node.item_data_ref.scene.instantiate()
		#host_sprite = item.get_node("%AnimatedSprite2D") # maybe check for Srpite2D as well
		#item.global_position = self.global_position
		#add_child(item)
