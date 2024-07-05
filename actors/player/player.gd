extends CharacterBody2D

const SPEED = 150.0
var anim: AnimatedSprite2D
var direction := Vector2.ZERO
var prev_direction := Vector2(0, 1)

var lure_scene = preload("res://objects/lure/lure.tscn")
var lure = null

func _ready():
	anim = $AnimatedSprite2D
	anim.connect("animation_finished", Callable(self, "on_animation_finished"))
	_goto("idle")

func on_animation_finished():
	if anim.animation == "cancel_cast_south": # or other directions
		_goto("idle")

func _always_process(_delta):
	direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))

func _always_physics_process(_delta):
	velocity = direction * SPEED
	
	if _current_state != "reel":
		move_and_slide()
	
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
	
	# If player hasn't canceled cast anim by moving, spawn lure.
	if _current_state == "fish":
		self.get_parent().add_child(new_lure)
		lure = new_lure

func remove_lure(cancel_cast: bool):
	if is_instance_valid(lure) and lure != null:
		if cancel_cast: # Reel a better word here?
			lure.cancel_cast()
			lure = null
		else:
			lure.queue_free()
			lure = null

#region State fish
func _state_fish_enter():
	# match direction ...
	anim.play("fish_south")
	
	cast_lure()

func _state_fish_process(_delta):
	if direction != Vector2(0,0):
		remove_lure(false)
		_goto("walk")
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_instance_valid(lure):
			if !lure.fish_hooked:
				remove_lure(true)
				# match direction ...
				anim.play("cancel_cast_south")
				# Goes to idle state once this animation is over.
				# Note: See on_animation_finished()
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
	# TODO: Should include fish sprite for catching.
	remove_lure(true)

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
	pass

func _state_walk_exit():
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
