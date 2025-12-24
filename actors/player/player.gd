extends CharacterBody2D

#TODO Player script needs de-complication pass.

signal pressedConfirm

const SPEED = 150.0
var direction := Vector2.ZERO
var prev_direction := Vector2(0, 1)

var radial_highlight_scene = preload("res://objects/radial_highlight/radial_highlight.tscn")
var item_drop_scene = preload("res://objects/item_drop/item_drop.tscn")
var lure_scene = preload("res://objects/lure/lure.tscn")

var caught_fish_to_display = null
var radial_highlight_to_display = null
var lure = null
var recent_caught_fish = {}
var yanking = false
var in_dialog = false
var has_been_cast = false
var inventory_open = false
var notification_displaying = false
var original_notification_sprite = null
var interacting = false

@export var camera_controller: Node2D
@export var camera: Camera2D
@export var item_drops_container: Node2D
#@export var tilemap

@onready var inventory = $Inventory
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_panel: Panel = %DialogPanel
@onready var dialog_label: RichTextLabel = %DialogLabel
@onready var dialog_confirm: Label = %DialogConfirm
@onready var notification_panel: Panel = %NotificationPanel
@onready var notification_text_label: Label = %NotificationTextLabel
@onready var notification_sprite: AnimatedSprite2D = %NotificationSprite
@onready var notification_sprite_control: Control = %NotificationSpriteControl
#@onready var dialog_button: Button = %DialogButton

func _ready():
	original_notification_sprite = notification_sprite.duplicate()
	inventory.visible = false
	dialog_panel.visible = false
	notification_panel.modulate.a = 0
	dialog_confirm.visible = false
	camera_controller.set_target(self)
	_goto("idle")


func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		pressedConfirm.emit()

func _on_inventory_item_dropped(item_data: Dictionary) -> void:
	drop_item(item_data, true)

func _on_inventory_equip_failed() -> void:
	render_notification("Can't Equip")

func _on_inventory_item_value_depleted(item_scene: PackedScene) -> void:
	render_notification("Item Depleted", item_scene)

func prep_fish_item_data(fish_data: Dictionary, fish_measurement: float) -> Dictionary:
	return {
		"scene": fish_data.scene,
		"name": fish_data.name,
		"weight": fish_measurement,
		"item_type": RefData.item_types.FISH,
		"buy_price": fish_data.buy_price,
		"sell_price": fish_data.sell_price,
	}

func pickup_item(item_data_ref: Dictionary) -> bool:
	var successful = inventory.pocket_item(item_data_ref)
	
	if not successful:
		render_notification("Backpack Full")
	
	return successful

func render_notification(notifcation_text: String, sprite_scene: PackedScene = null):
	if not notification_displaying:
		for child in notification_sprite_control.get_children():
			child.queue_free()
			
		if sprite_scene:
			var sprite: Node2D = sprite_scene.instantiate()
			sprite.position.x += 32
			sprite.position.y += 32
			notification_sprite_control.add_child(sprite)
		else:
			notification_sprite_control.add_child(original_notification_sprite.duplicate())
			
		notification_displaying = true
		notification_text_label.text = notifcation_text
		var fade_in_tween = create_tween()
		await fade_in_tween.tween_property(notification_panel, "modulate:a", 1, 0.5).finished
		var fade_out_tween = create_tween()
		fade_out_tween.tween_interval(1.5)
		await fade_out_tween.tween_property(notification_panel, "modulate:a", 0, 0.5).finished
		notification_displaying = false

func drop_item(dropped_item_data: Dictionary, recent_manual_drop = false):
	var item_drop = item_drop_scene.instantiate()
	item_drop.set_item_data(dropped_item_data)
	item_drop.global_position = self.global_position # make a bit random
	item_drop.global_position.x += randf_range(0, 50) * random_sign()
	item_drop.global_position.y += randf_range(0, 50) * random_sign()
	item_drop.recent_manual_drop = recent_manual_drop
	item_drops_container.add_child(item_drop)

func random_sign() -> int:
	var num = floor(randi_range(0, 2))
	if num == 0:
		return 1
	else:
		return -1
		

func dialog_say(s: String) -> void:
	dialog_label.text = s
	dialog_label.visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(dialog_label, "visible_ratio", 1.0, 0.75)
	#dialog_button.disabled = true
	await tween.finished
	dialog_confirm.visible = true
	var tw = create_tween()
	tw.set_loops()
	tw.tween_property(dialog_confirm, "self_modulate:a", 0, 0.5)
	tw.tween_property(dialog_confirm, "self_modulate:a", 1, 0.5)
	#dialog_button.disabled = false
	#await dialog_button.pressed
	await pressedConfirm
	dialog_confirm.visible = false

func custom_dialog(dialogs: Array[String]) -> void:
	dialog_panel.visible = true
	in_dialog = true
	
	for dialog in dialogs:
		await dialog_say(dialog)
	
	in_dialog = false
	on_reset_ui()

func caught_fish_dialog(fish_data: Dictionary, fish_measurement: float, pocket_successful: bool) -> void:
	dialog_panel.visible = true
	in_dialog = true
	await dialog_say(fish_data.message)
	await dialog_say("I caught a %s weighing %.2f pounds!" % [fish_data.name, fish_measurement])
	if not pocket_successful:
		await dialog_say("Aww my pockets are full. I'll leave this on the ground for now.")
		
	in_dialog = false
	
func on_reset_ui():
	dialog_panel.visible = false

func wait_for_lure_to_return():
	if is_instance_valid(lure):
		return lure.tree_exited
	else:
		null

func determine_fish_measurement(fish_data: Dictionary) -> float:
	var fish_measurement = randf_range(fish_data.min_weight, fish_data.max_weight)
	return fish_measurement

func _always_process(_delta):
	direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))

func _always_physics_process(_delta):
	pass

func on_zoom_camera():
	var tween = get_tree().create_tween()
	var new_zoom_vec2 = Vector2(1.5, 1.5)
	tween.tween_property(camera, "zoom", new_zoom_vec2, 0.2).set_ease(Tween.EaseType.EASE_IN_OUT)

func on_reset_camera():
	var tween = get_tree().create_tween()
	var reset_zoom_vec2 = Vector2(1.0, 1.0)
	tween.tween_property(camera, "zoom", reset_zoom_vec2, 0.35).set_ease(Tween.EaseType.EASE_IN_OUT)

func render_radial_highlight(pos):
	var new_highlight = radial_highlight_scene.instantiate()
	radial_highlight_to_display = new_highlight
	#var highlight_pos = Vector2(self.global_position.x, self.global_position.y) # self.global_position
	pos.y -= 67
	pos.x -= 70
	new_highlight.set_position(pos)
	self.add_child(new_highlight)

func cast_lure():
	if is_instance_valid(lure) and lure != null:
		camera_controller.set_target(self)
		has_been_cast = false
		lure.queue_free()
		lure == null
	
	var new_lure = lure_scene.instantiate()
	var lure_pos = Vector2(self.global_position.x, self.global_position.y) # self.global_position
	new_lure.target = lure_pos + (prev_direction * 150)
	#lure_pos += prev_direction * 150
	new_lure.set_position(lure_pos)
	new_lure.player_ref = self
	
	# Set camera to follow lure.
	camera_controller.set_target(new_lure)
	
	# Set delay to match up with casting animation.
	await get_tree().create_timer(0.5).timeout
	
	# If player hasn't canceled cast anim by moving, spawn lure. #TODO this still needed?
	if _current_state == "fish":
		self.get_parent().add_child(new_lure)
		lure = new_lure

func yank_lure():
	if is_instance_valid(lure) and lure != null:
		lure.yank()
		#lure = null

#region State fish
func _state_fish_enter():
	match prev_direction:
		Vector2.DOWN:
			anim.play("fish_south")
		Vector2.UP:
			anim.play("fish_south")
			#anim.play("fish_north")
		Vector2.RIGHT:
			anim.play("fish_east")
		Vector2.LEFT:
			anim.play("fish_west")
		Vector2(-1, 1):
			anim.play("fish_southwest")
		Vector2(1, 1):
			anim.play("fish_southeast")
		Vector2(-1, -1):
			anim.play("fish_south")
			#anim.play("fish_northwest")
		Vector2(1, -1):
			anim.play("fish_south")
			#anim.play("fish_northeast")
	
	cast_lure()

func play_yank_animation():
	match prev_direction:
		Vector2.DOWN:
			anim.play("yank_south")
		Vector2.UP:
			anim.play("yank_south")
			#anim.play("yank_north")
		Vector2.RIGHT:
			anim.play("yank_east")
		Vector2.LEFT:
			anim.play("yank_west")
		Vector2(-1, 1):
			anim.play("yank_southwest")
		Vector2(1, 1):
			anim.play("yank_southeast")
		Vector2(-1, -1):
			anim.play("yank_south")
			#anim.play("yank_northwest")
		Vector2(1, -1):
			anim.play("yank_south")
			#anim.play("yank_northeast")

func _state_fish_process(_delta):
	if direction != Vector2(0,0) and not yanking:
		yanking = true
		yank_lure()
		play_yank_animation()
		await wait_for_lure_to_return()
		yanking = false
		_goto("idle")
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_instance_valid(lure):
			if !lure.fish_hooked: # cancel cast
				yank_lure()
				play_yank_animation()
				await wait_for_lure_to_return()
				_goto("idle")
			else: # sucessful catch!
				_goto("reel")
				lure.player_input_press()

func _state_fish_physics_process(_delta):
	pass

func _state_fish_exit():
	pass

#endregion

#region State reel
func _state_reel_enter():
	match prev_direction:
		Vector2.DOWN:
			anim.play("reel_south")
		Vector2.UP:
			anim.play("reel_south")
			#anim.play("reel_north")
		Vector2.RIGHT:
			anim.play("reel_east")
		Vector2.LEFT:
			anim.play("reel_west")
		Vector2(-1, 1):
			anim.play("reel_southwest")
		Vector2(1, 1):
			anim.play("reel_southeast")
		Vector2(-1, -1):
			anim.play("reel_south")
			#anim.play("reel_northwest")
		Vector2(1, -1):
			anim.play("reel_south")
			#anim.play("reel_northeast")

func _state_reel_process(_delta):
	pass

func _state_reel_physics_process(_delta):
	pass

func _state_reel_exit():
	play_yank_animation()
	yank_lure()
	await wait_for_lure_to_return()
	on_zoom_camera()
	_goto("get_item")
	
#endregion

#region State idle
func _state_idle_enter():
	match prev_direction:
		Vector2.DOWN:
			anim.play("idle_south")
		Vector2.UP:
			anim.play("idle_north")
		Vector2.RIGHT:
			anim.play("idle_east")
		Vector2.LEFT:
			anim.play("idle_west")
		Vector2(-1, 1):
			anim.play("idle_southwest")
		Vector2(1, 1):
			anim.play("idle_southeast")
		Vector2(-1, -1):
			anim.play("idle_northwest")
		Vector2(1, -1):
			anim.play("idle_northeast")

func _state_idle_process(_delta):
	if interacting and not has_been_cast:
		return 
		
	if Input.is_action_just_pressed("ui_accept") and not has_been_cast and not inventory_open:
		var areas = $ItemPickupArea2D.get_overlapping_areas()
		for area: Area2D in areas:
			if area.is_in_group("interactable_zone"):
				if not interacting:
					var interactable_zone = area.get_parent()
					interactable_zone.interact()
				
				return
		
		print("hello?")
		if inventory.get_equipped_rod() != {}:
			_goto("fish")
			has_been_cast = true
		else:
			render_notification("Equip Rod")
	elif direction != Vector2(0,0) and not inventory_open:
		_goto("walk")
	
	if Input.is_action_just_pressed("toggle_inventory") and not has_been_cast and not inventory_open:
		inventory.render_backpack(0)
		inventory_open = true
		inventory.visible = true
	elif Input.is_action_just_pressed("toggle_inventory") and not has_been_cast and inventory_open:
		inventory_open = false
		inventory.visible = false

func _state_idle_physics_process(_delta):
	pass

func _state_idle_exit():
	pass
#endregion

#region State walk
func _state_walk_enter():
	pass

func _state_walk_process(_delta):
	if direction == Vector2(0,0):
		_goto("idle")
	else:
		match direction:
			Vector2.DOWN:
				anim.play("walk_south")
			Vector2.UP:
				anim.play("walk_north")
			Vector2.RIGHT:
				anim.play("walk_east")
			Vector2.LEFT:
				anim.play("walk_west")
			Vector2(-1, 1):
				anim.play("walk_southwest")
			Vector2(1, 1):
				anim.play("walk_southeast")
			Vector2(-1, -1):
				anim.play("walk_northwest")
			Vector2(1, -1):
				anim.play("walk_northeast")
	
		prev_direction = direction

func _state_walk_physics_process(_delta):
	velocity = direction * SPEED
	move_and_slide()
	
	#if !movement_locked:
		#move_and_slide()

func _state_walk_exit():
	pass
#endregion

#region State get item
func _state_get_item_enter():
	print(recent_caught_fish)
	await get_tree().create_timer(0.5).timeout
	anim.play("get_item")
	caught_fish_to_display = recent_caught_fish.scene.instantiate()
	caught_fish_to_display.position.y -= 75
	render_radial_highlight(caught_fish_to_display.position)
	self.add_child(caught_fish_to_display)
	
	var fish_measurement = determine_fish_measurement(recent_caught_fish)
	var new_item_data = prep_fish_item_data(recent_caught_fish, fish_measurement)
	var pocket_successful = inventory.pocket_item(new_item_data)
	await caught_fish_dialog(recent_caught_fish, fish_measurement, pocket_successful)
	
	if not pocket_successful:
		drop_item(new_item_data)

func _state_get_item_process(_delta):
	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(caught_fish_to_display) and !in_dialog:
		caught_fish_to_display.queue_free()
		caught_fish_to_display = null
		radial_highlight_to_display.queue_free()
		radial_highlight_to_display = null
		on_reset_ui()
		on_reset_camera()
		_goto("idle")

func _state_get_item_physics_process(_delta):
	pass

func _state_get_item_exit():
	pass
#endregion

func goto_wait_state():
	_goto("wait")

#region State wait
func _state_wait_enter():
	pass

func _state_wait_process(_delta):
	pass

func _state_wait_physics_process(_delta):
	pass

func _state_wait_exit():
	pass
#endregion

#region State machine core
# do not touch please
var _states: Dictionary
var _current_state: StringName
func __opt_func(n: StringName) -> Callable:
	return Callable(self, n) if self.has_method(n) else Callable()
func _add_state(state_name: String) -> void:
	_states[state_name] = {
		process = __opt_func("_state_" + state_name + "_process"),
		physics_process = __opt_func("_state_" + state_name + "_physics_process"),
		enter = __opt_func("_state_" + state_name + "_enter"),
		exit = __opt_func("_state_" + state_name + "_exit") }
	if _states[state_name].values().count(Callable()) == 4:
		push_warning("State %s has no state functions! Typo?" % [state_name])
		breakpoint
func _goto(state_name: StringName) -> void:
	if _current_state and _states[_current_state].get("exit", Callable()): _states[_current_state].exit.call()
	_current_state = state_name
	if not _current_state: return
	if not _current_state in _states: _add_state(_current_state)
	if _current_state and _states[_current_state].get("enter", Callable()): _states[_current_state].enter.call()
func _process(delta: float) -> void:
	if &"_always_process" in self: (self as Variant)._always_process(delta)
	if _current_state and _states[_current_state].get("process", Callable()): _states[_current_state].process.call(delta)
func _physics_process(delta: float) -> void:
	if &"_always_physics_process" in self: (self as Variant)._always_physics_process(delta)
	if _current_state and _states[_current_state].get("physics_process", Callable()): _states[_current_state].physics_process.call(delta)
#endregion
