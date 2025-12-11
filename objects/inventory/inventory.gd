extends CanvasLayer

@onready var backpack_panel: Panel = %BackpackPanel

func _ready():
	init_backpack_pockets()
	#backpack_panel.visible = false

func init_backpack_pockets(): #starting_hat_index: int):
	var pocket_pos_y = -90
	var pocket_pos_x = 15
	#var hat_index = starting_hat_index
	
	for r in range(3):
		pocket_pos_y += 105
		pocket_pos_x = 15
		
		for c in range(4):
			#create_hat_catalog_item(Vector2(button_pos_x, button_pos_y), hat_index)
			render_pocket(Vector2(pocket_pos_x, pocket_pos_y))
			#hat_index += 1
			pocket_pos_x += 105

func render_pocket(pos: Vector2): #(pos: Vector2, hat_index: int):	
		#var hat_scene_file = hat_keys[hat_index]
	var item_height = 100
	var item_length = 100
	var new_pocket = Button.new()
	#new_hat_button_panel.focus_mode = Control.FOCUS_CLICK
	new_pocket.set_position(pos)
	new_pocket.set_size(Vector2(item_length, item_height))
	backpack_panel.add_child(new_pocket)
