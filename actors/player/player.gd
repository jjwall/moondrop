extends CharacterBody2D

#TODO Player script needs de-complication pass.

signal pressedConfirm

const SPEED = 150.0
var direction := Vector2.ZERO
var prev_direction := Vector2(0, 1)

var lure_scene = preload("res://objects/lure/lure.tscn")
var caught_fish_to_display = null
var lure = null
var recent_caught_fish = {}
var yanking = false
var in_dialog = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_panel: Panel = %DialogPanel
@onready var dialog_label: Label = %DialogLabel
#@onready var dialog_button: Button = %DialogButton

func _ready():
	dialog_panel.visible = false
	_goto("idle")


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		pressedConfirm.emit()

func dialog_say(s: String) -> void:
	dialog_label.text = s
	dialog_label.visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(dialog_label, "visible_ratio", 1.0, 0.5)
	#dialog_button.disabled = true
	await tween.finished
	#dialog_button.disabled = false
	#await dialog_button.pressed
	await pressedConfirm

func caught_fish_dialog(fish_data: Dictionary) -> void:
	dialog_panel.visible = true
	in_dialog = true
	await dialog_say(fish_data.message)
	await dialog_say("This badboy weighs 22 pounds!")
	in_dialog = false
	
func on_reset_ui():
	dialog_panel.visible = false

func wait_for_lure_to_return():
	if is_instance_valid(lure):
		return lure.tree_exited
	else:
		null

func _always_process(_delta):
	direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))

func _always_physics_process(_delta):
	pass

func on_zoom_camera():
	var camera_node: Camera2D = self.get_node("Camera2D")
	var tween = get_tree().create_tween()
	var new_zoom_vec2 = Vector2(1.5, 1.5)
	tween.tween_property(camera_node, "zoom", new_zoom_vec2, 0.2).set_ease(Tween.EaseType.EASE_IN_OUT)

func on_reset_camera():
	var camera_node: Camera2D = self.get_node("Camera2D")
	var tween = get_tree().create_tween()
	var reset_zoom_vec2 = Vector2(1.0, 1.0)
	tween.tween_property(camera_node, "zoom", reset_zoom_vec2, 0.2).set_ease(Tween.EaseType.EASE_IN_OUT)

func cast_lure():
	if is_instance_valid(lure) and lure != null:
		lure.queue_free()
		lure == null
	
	var new_lure = lure_scene.instantiate()
	var lure_pos = Vector2(self.global_position.x, self.global_position.y) # self.global_position
	new_lure.target = lure_pos + (prev_direction * 150)
	#lure_pos += prev_direction * 150
	new_lure.set_position(lure_pos)
	new_lure.player_ref = self
	
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
	# match direction ...
	anim.play("fish_south")
	
	cast_lure()

func _state_fish_process(_delta):
	if direction != Vector2(0,0) and not yanking:
		yanking = true
		yank_lure()
		# match direction ...
		anim.play("yank_south")
		await wait_for_lure_to_return()
		yanking = false
		_goto("idle")
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_instance_valid(lure):
			if !lure.fish_hooked: # cancel cast
				yank_lure()
				# match direction ...
				anim.play("yank_south")
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
	# match direction ...
	anim.play("reel_south")

func _state_reel_process(_delta):
	pass

func _state_reel_physics_process(_delta):
	pass

func _state_reel_exit():
	# match direction ...
	anim.play("yank_south")
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
	if Input.is_action_just_pressed("ui_accept"):
		_goto("fish")
	elif direction != Vector2(0,0):
		_goto("walk")

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
	self.add_child(caught_fish_to_display)
	caught_fish_dialog(recent_caught_fish)

func _state_get_item_process(_delta):
	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(caught_fish_to_display) and !in_dialog:
		caught_fish_to_display.queue_free()
		caught_fish_to_display = null
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
