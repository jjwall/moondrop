extends CanvasLayer

signal item_value_depleted(item_scene: PackedScene)
signal item_dropped(item_data: Dictionary)
signal equip_failed

@onready var backpack_panel: Panel = %BackpackPanel
@onready var item_profile_panel: Panel = %ItemProfilePanel
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_description_label: Label = %ItemDescriptionLabel

#const outline_shader = preload("res://assets/shaders/outline.gdshader")
const outline_material = preload("res://assets/materials/outline.tres")

var rod_silhouette_scene = preload("res://objects/inventory/rod_silhouette.tscn")
var bait_silhouette_scene = preload("res://objects/inventory/bait_silhouette.tscn")

var dragging = false
var item_being_dragged = null
var starting_drag_pos = Vector2(0, 0)
var dragged_item_pocket_index = -1
var pocket_index_to_swap_with = -1
var mouse_exited_last = false

var item_structure = {
	"scene": "blah",
	"name": "my cool fish",
	"weight": 55.55,
	# aquire_on: new Date()
}

var total_pockets = 18
var rod_equip_index = 16
var bait_equip_index = 17
var items_in_pockets = []

func _ready():
	for i in range(total_pockets):
		items_in_pockets.push_back(null)
		
	render_backpack(0)

func _process(_delta: float) -> void:
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		item_being_dragged.global_position = Vector2(mousepos.x, mousepos.y)

func get_equipped_rod() -> Dictionary:
	if items_in_pockets[rod_equip_index] != null:
		return items_in_pockets[rod_equip_index]
	else:
		return {}

func get_equipped_bait() -> Dictionary:
	if items_in_pockets[bait_equip_index] != null:
		return items_in_pockets[bait_equip_index]
	else:
		return {}

func reset_item_details():
	# Wipe previously rendered item profile.
	for child in item_profile_panel.get_children():
		child.queue_free()
		
	item_name_label.text = ""
	item_description_label.text = ""

func render_backpack(starting_pocket_index: int, selected_pocket_index = -1):
	reset_item_details()
	
	# Wipe previously rendered catalog items.
	for child in backpack_panel.get_children():
		child.queue_free()
		
	return init_backpack_pockets(starting_pocket_index, selected_pocket_index)

func check_item_type_and_swap_contents(index_a: int, index_b: int):
	if rod_equip_index == index_b:
		if items_in_pockets[index_a].item_type == RefData.item_types.ROD:
			swap_pocket_contents(index_a, index_b)
		else:
			equip_failed.emit()
	elif bait_equip_index == index_b:
		if items_in_pockets[index_a].item_type == RefData.item_types.BAIT:
			swap_pocket_contents(index_a, index_b)
		else:
			equip_failed.emit()
	elif rod_equip_index == index_a and items_in_pockets[index_b] != null:
		if items_in_pockets[index_b].item_type == RefData.item_types.ROD:
			swap_pocket_contents(index_a, index_b)
		else:
			equip_failed.emit()
	elif bait_equip_index == index_a and items_in_pockets[index_b] != null:
		if items_in_pockets[index_b].item_type == RefData.item_types.BAIT:
			swap_pocket_contents(index_a, index_b)
		else:
			equip_failed.emit()
	else: # Regular item swap.
		swap_pocket_contents(index_a, index_b)

func handle_item_value_stack(max_value: int, index_a: int, index_b: int):
	var item_a_value: int = items_in_pockets[index_a].value
	var item_b_value: int = items_in_pockets[index_b].value
	var new_a_value = 0
	var new_b_value = 0
	
	if (item_a_value + item_b_value) > max_value:
		new_a_value = max_value
		new_b_value = item_b_value - (max_value - item_a_value) # - item_a_value
	else:
		new_a_value = item_a_value + item_b_value
		new_b_value = 0
		
	if new_a_value > 0:
		items_in_pockets[index_a].value = new_a_value
		
		if new_b_value == 0:
			items_in_pockets[index_b] = null
		else:
			items_in_pockets[index_b].value = new_b_value
			
	elif new_b_value > 0:
		items_in_pockets[index_b].value = new_b_value
		
		if new_a_value == 0:
			items_in_pockets[index_a].value = null
		else:
			items_in_pockets[index_a].value = new_a_value
			

func swap_pocket_contents(index_a: int, index_b: int):
	# If same item and have value, handle the item value stack merges.
	if items_in_pockets[index_a] != null and items_in_pockets[index_b] != null and items_in_pockets[index_a].has("value") and items_in_pockets[index_b].has("value") and items_in_pockets[index_a].name == items_in_pockets[index_b].name:
		if index_a != index_b: # merge values if not the same item.
			handle_item_value_stack(items_in_pockets[index_a].max_value, index_a, index_b)
			
	var temp = items_in_pockets[index_a]
	items_in_pockets[index_a] = items_in_pockets[index_b]
	items_in_pockets[index_b] = temp

# Returns if pocketing was successful or not. Failure means pockets are full.
func pocket_item(item_data: Dictionary) -> bool:
	var first_empty_pocket_index = items_in_pockets.find(null)
	
	if first_empty_pocket_index != -1 and first_empty_pocket_index != rod_equip_index and first_empty_pocket_index != bait_equip_index:
		items_in_pockets[first_empty_pocket_index] = item_data
		return true
	else:
		print("too many items in pockets!")
		return false

func drop_item(pocket_index: int):
	var dropped_item_data = remove_item_from_pocket(pocket_index)
	item_dropped.emit(dropped_item_data)

func select_item(selected_item: Node2D, pocket_index: int):
	var new_material = outline_material.duplicate()
	selected_item.get_child(0).material = new_material
	var item_data = items_in_pockets[pocket_index]
	item_name_label.text = item_data.name
	
	render_item_description(item_data)
	render_item_profile(item_data.scene)

func render_item_description(item_data: Dictionary):
	match item_data.item_type:
		RefData.item_types.FISH:
			item_description_label.text = "A %s weighing %.2f pounds! This was caught on 12/12/2025." % [item_data.name, item_data.weight]
		RefData.item_types.ROD:
			item_description_label.text = "A %s. %s" % [item_data.name, item_data.description]
		RefData.item_types.BAIT:
			item_description_label.text = "%s" % [item_data.description]

func render_item_profile(item_scene: PackedScene):
	var item_profile: Node2D = item_scene.instantiate()
	var pos = item_profile_panel.position
	pos.x += 48
	pos.y += 48
	item_profile.scale.x *= 1.5
	item_profile.scale.y *= 1.5
	item_profile.set_position(pos)
	item_profile_panel.add_child(item_profile)

func init_backpack_pockets(starting_pocket_index: int, selected_pocket_index = -1) -> Node2D:
	var pocket_pos_y = -55
	var pocket_pos_x = 15
	var pocket_index = starting_pocket_index
	var selected_pocket_item = null
	
	# Init pockets.
	for r in range(4):
		pocket_pos_y += 70
		pocket_pos_x = 15
		
		for c in range(4):
			if items_in_pockets.size() > pocket_index:
				var possible_selected_item = render_pocket_and_item(Vector2(pocket_pos_x, pocket_pos_y), pocket_index, selected_pocket_index)
				if possible_selected_item != null:
					selected_pocket_item = possible_selected_item
					
				pocket_index += 1
			pocket_pos_x += 70
		
	pocket_pos_x += 39
	
	# Int equip slots.
	for i in range(2):
		var possible_selected_item = render_pocket_and_item(Vector2(pocket_pos_x, pocket_pos_y), pocket_index, selected_pocket_index)
		if possible_selected_item != null:
			selected_pocket_item = possible_selected_item
			
		pocket_index += 1
		pocket_pos_x += 70
	
	return selected_pocket_item

func render_pocket_and_item(pos: Vector2, pocket_index: int, selected_pocket_index = -1) -> Node2D:
	var selected_pocket_item = null
	var new_pocket = render_pocket(pos)
	new_pocket.mouse_entered.connect(on_pocket_mouse_entered.bind(pocket_index))
	new_pocket.mouse_exited.connect(on_pocket_mouse_exited)

	if items_in_pockets.size() > pocket_index and items_in_pockets[pocket_index] != null:
		var value_label = null
		
		# Render value of item near item icon.
		if items_in_pockets[pocket_index].has("value"):
			if items_in_pockets[pocket_index].value == 0:
				item_value_depleted.emit(items_in_pockets[pocket_index].scene)
				items_in_pockets[pocket_index] = null
				render_bait_silhouette(new_pocket)
			else:
				value_label = Label.new()
				value_label.text = "%s" % [items_in_pockets[pocket_index].value]
				value_label.position.x -= 25
				value_label.position.y += 14
				value_label.add_theme_font_size_override("font_size", 19)
				
				if items_in_pockets[pocket_index].value == items_in_pockets[pocket_index].max_value:
					value_label.add_theme_color_override("font_color", Color(0, 1, 0))
				
			#item_in_pocket.add_child(value_label)
		
		if items_in_pockets[pocket_index] != null:
			var item_in_pocket = render_item(items_in_pockets[pocket_index], pos)
			new_pocket.button_down.connect(on_pocket_button_down.bind(item_in_pocket, pocket_index))
			new_pocket.button_up.connect(on_pocket_button_up)
			
			if value_label != null:
				item_in_pocket.add_child(value_label)
		
			if selected_pocket_index == pocket_index:
				selected_pocket_item = item_in_pocket
				
	elif pocket_index == rod_equip_index: # Rod not equipped.
		render_rod_silhouette(new_pocket)
	elif pocket_index == bait_equip_index: # Bait not equipped.
		render_bait_silhouette(new_pocket)
	
	return selected_pocket_item

func render_rod_silhouette(pocket: Button):
	var rod_silhouette: Node2D = rod_silhouette_scene.instantiate()
	rod_silhouette.position.x += 32
	rod_silhouette.position.y += 32
	pocket.add_child(rod_silhouette)

func render_bait_silhouette(pocket: Button):
	var bait_silhouette: Node2D = bait_silhouette_scene.instantiate()
	bait_silhouette.position.x += 32
	bait_silhouette.position.y += 32
	pocket.add_child(bait_silhouette)

func on_pocket_button_down(item: Node2D, pocket_index: int):
	dragging = true
	starting_drag_pos = item.position
	item_being_dragged = item
	item_being_dragged.z_index += 1
	dragged_item_pocket_index = pocket_index
	pocket_index_to_swap_with = pocket_index
	
	# Clear shader to not highlight when dragging.
	item.get_child(0).material = null

func on_pocket_button_up():
	if dragging:
		if dragged_item_pocket_index == pocket_index_to_swap_with and mouse_exited_last:
			drop_item(dragged_item_pocket_index)
			mouse_exited_last = false
		else:
			check_item_type_and_swap_contents(dragged_item_pocket_index, pocket_index_to_swap_with)
			#swap_pocket_contents(dragged_item_pocket_index, pocket_index_to_swap_with)
			item_being_dragged.z_index -= 1
		
		dragging = false
		var selected_item = render_backpack(0, pocket_index_to_swap_with)
		
		if selected_item != null:
			select_item(selected_item, pocket_index_to_swap_with)

func on_pocket_mouse_entered(pocket_index: int):
	if dragging:
		mouse_exited_last = false
		pocket_index_to_swap_with = pocket_index

func on_pocket_mouse_exited():
	if dragging:
		mouse_exited_last = true
		pocket_index_to_swap_with = dragged_item_pocket_index

func remove_item_from_pocket(pocket_index: int):
	var dropped_item_data = items_in_pockets[pocket_index]
	#items_in_pockets.remove_at(pocket_index)
	items_in_pockets[pocket_index] = null
	render_backpack(0)
	return dropped_item_data

func render_item(item_data: Dictionary, pos: Vector2) -> Node2D:
	var item: Node2D = item_data.scene.instantiate()
	pos.x += 32
	pos.y += 32
	item.z_index += 1
	item.set_position(pos)
	backpack_panel.add_child(item)
	return item

func render_pocket(pos: Vector2) -> Button: #(pos: Vector2, hat_index: int):
	var item_height = 65
	var item_length = 65
	var new_pocket = Button.new()
	#new_pocket.focus_mode = Control.FOCUS_CLICK
	new_pocket.set_position(pos)
	new_pocket.set_size(Vector2(item_length, item_height))
	backpack_panel.add_child(new_pocket)
	return new_pocket
