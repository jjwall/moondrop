extends CanvasLayer

signal item_dropped(item_data: Dictionary)

@onready var backpack_panel: Panel = %BackpackPanel

var dragging = false
var item_being_dragged = null
var starting_drag_pos = Vector2(0, 0)
var dragged_item_pocket_index = 0
var pocket_index_to_swap_with = 0

var item_structure = {
	"scene": "blah",
	"name": "my cool fish",
	"weight": 55.55,
	# aquire_on: new Date()
}

var total_pockets = 12
var items_in_pockets = []

func _ready():
	for i in range(total_pockets):
		items_in_pockets.push_back(null)
		
	render_backpack(0)
	#backpack_panel.visible = false

func _process(_delta: float) -> void:
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		item_being_dragged.global_position = Vector2(mousepos.x, mousepos.y)

func render_backpack(starting_pocket_index: int):
	# Wipe previously rendered catalog items.
	for child in backpack_panel.get_children():
		child.queue_free()
		
	init_backpack_pockets(starting_pocket_index)

func swap_pocket_contents(index_a: int, index_b: int):
	var temp = items_in_pockets[index_a]
	items_in_pockets[index_a] = items_in_pockets[index_b]
	items_in_pockets[index_b] = temp

# Returns if pocketing was successful or not. Failure means pockets are full.
func pocket_item(item_data: Dictionary) -> bool:
	var first_empty_pocket_index = items_in_pockets.find(null)
	
	if first_empty_pocket_index != -1:
		items_in_pockets[first_empty_pocket_index] = item_data
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
			new_pocket.button_up.connect(on_pocket_button_up)
			new_pocket.mouse_entered.connect(on_pocket_mouse_entered.bind(pocket_index))
			# if pocket_index < items_in_pockets.size():
			if items_in_pockets[pocket_index] != null:
				var item_in_pocket = render_item(items_in_pockets[pocket_index], Vector2(pocket_pos_x, pocket_pos_y))
				new_pocket.button_down.connect(on_pocket_button_down.bind(item_in_pocket, pocket_index))
			# else: empty pocket
				
			pocket_index += 1
			pocket_pos_x += 105

func on_pocket_button_down(item: Node2D, pocket_index: int):
	dragging = true
	starting_drag_pos = item.position
	item_being_dragged = item
	item_being_dragged.z_index += 1
	dragged_item_pocket_index = pocket_index
	pocket_index_to_swap_with = pocket_index
	
	# For now, drop item when pressed.
	#var dropped_item_data = remove_item_from_pocket(pocket_index)
	#print(dropped_item_data)
	#item_dropped.emit(dropped_item_data)

func on_pocket_button_up():
	if dragging:
		swap_pocket_contents(dragged_item_pocket_index, pocket_index_to_swap_with)
		item_being_dragged.z_index -= 1
		#item_being_dragged.position = starting_drag_pos
		dragging = false
		render_backpack(0)
	#item.position = starting_drag_pos

func on_pocket_mouse_entered(pocket_index: int):
	if dragging:
		pocket_index_to_swap_with = pocket_index

func remove_item_from_pocket(pocket_index: int):
	var dropped_item_data = items_in_pockets[pocket_index]
	print(pocket_index)
	#items_in_pockets.remove_at(pocket_index)
	items_in_pockets[pocket_index] = null
	render_backpack(0)
	return dropped_item_data

func render_item(item_data: Dictionary, pos: Vector2) -> Node2D:
	var item: Node2D = item_data.scene.instantiate()
	pos.x += 48
	pos.y += 48
	item.z_index += 1
	item.set_position(pos)
	backpack_panel.add_child(item)
	return item

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
