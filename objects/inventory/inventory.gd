extends CanvasLayer

signal item_dropped(item_data: Dictionary)

@onready var backpack_panel: Panel = %BackpackPanel

var item_structure = {
	"scene": "blah",
	"name": "my cool fish",
	"weight": 55.55,
	# aquire_on: new Date()
}

var total_pockets = 12
var items_in_pockets = []

func _ready():
	render_backpack(0)
	#backpack_panel.visible = false

func render_backpack(starting_pocket_index: int):
	# Wipe previously rendered catalog items.
	for child in backpack_panel.get_children():
		child.queue_free()
		
	init_backpack_pockets(starting_pocket_index)

# Returns if pocketing was successful or not. Failure means pockets are full.
func pocket_item(item_data: Dictionary) -> bool:
	if items_in_pockets.size() < total_pockets:
		items_in_pockets.push_back(item_data)
		return true
	else:
		print("too many items in pockets!")
		return false

func init_backpack_pockets(starting_pocket_index: int):
	var pocket_pos_y = -90
	var pocket_pos_x = 15
	var pocket_index = starting_pocket_index
	
	for r in range(3):
		pocket_pos_y += 105
		pocket_pos_x = 15
		
		for c in range(4):
			var new_pocket = render_pocket(Vector2(pocket_pos_x, pocket_pos_y))
			if pocket_index < items_in_pockets.size():
				render_item(items_in_pockets[pocket_index], Vector2(pocket_pos_x, pocket_pos_y))
				new_pocket.pressed.connect(on_pocket_pressed.bind(pocket_index))
			# else: empty pocket
				
			pocket_index += 1
			pocket_pos_x += 105

func on_pocket_pressed(pocket_index: int):
	# For now, drop item when pressed.
	var dropped_item_data = remove_item_from_pocket(pocket_index)
	print(dropped_item_data)
	item_dropped.emit(dropped_item_data)
	# signal up drop item data

func remove_item_from_pocket(pocket_index: int):
	var dropped_item_data = items_in_pockets[pocket_index]
	print(pocket_index)
	items_in_pockets.remove_at(pocket_index)
	render_backpack(0)
	return dropped_item_data

func render_item(item_data: Dictionary, pos: Vector2):
	var item: Node2D = item_data.scene.instantiate()
	pos.x += 48
	pos.y += 48
	item.set_position(pos)
	backpack_panel.add_child(item)

func render_pocket(pos: Vector2) -> Button: #(pos: Vector2, hat_index: int):	
		#var hat_scene_file = hat_keys[hat_index]
	var item_height = 100
	var item_length = 100
	var new_pocket = Button.new()
	#new_hat_button_panel.focus_mode = Control.FOCUS_CLICK
	new_pocket.set_position(pos)
	new_pocket.set_size(Vector2(item_length, item_height))
	backpack_panel.add_child(new_pocket)
	return new_pocket
