extends CharacterBody2D

const SPEED = 300.0
var anim: AnimatedSprite2D

func _ready():
	anim = $AnimatedSprite2D
	_goto("idle_front")
	print("HEEEEYHY")

func _always_process(_delta):
	pass

func _always_physics_process(delta):
	var direction = Vector2(0, 0)
	if Input.is_action_just_pressed("ui_left"):
		direction = Vector2(-1, 0)
		anim.play("walk_side")
		anim.flip_h = false
		#_goto("walk_front")
	elif Input.is_action_just_pressed("ui_right"):
		direction = Vector2(1, 0)
		anim.play("walk_side")
		anim.flip_h = true
		#_goto("walk_side")
	elif Input.is_action_just_pressed("ui_down"):
		direction = Vector2(0, 1)
		anim.play("walk_front")
		#_goto("walk_front")
	elif Input.is_action_just_pressed("ui_up"):
		direction = Vector2(0, -1)
		anim.play("walk_back")
		#_goto("walk_back")
	#else:
		#move_toward(velocity.x, 0, SPEED)
		
	velocity += direction * SPEED
	
	move_and_slide()

#region State idle_front
func _state_idle_front_enter():
	print("hi")
	anim.play("idle_front")

func _state_idle_front_process(_delta):
	print("hellooo")
#
func _state_idle_front_physics_process(_delta):
	print("hiiiii")

func _state_idle_front_exit():
	print("helloooo")
	#endregion

#region State walk_front
func _state_walk_front_enter():
	print("hello???")
	anim.play("walk_front")

#func _state_idle_front_process(delta):
	#print("hellooo")
#
#func _state_idle_physics_process(delta):
	#print("hiiiii")

#func _state_idle_exit():
	#print("helloooo")
	#endregion


#region State machine core
# do not touch please
var _states: Dictionary
var _current_state: StringName
func __opt_func(n: StringName) -> Callable:
	return Callable(self, n) if self.has_method(n) else Callable()
func _add_state(state_name: String) -> void:
	_states[state_name] = {
		process = __opt_func("_state" + state_name + "_process"),
		physics_process = __opt_func("_state" + state_name + "_physics_process"),
		enter = __opt_func("_state" + state_name + "_enter"),
		exit = __opt_func("_state" + state_name + "_exit") }
	if _states[state_name].values().count(Callable()) < 4:
		push_warning("State %s has no state functions! Typo?" % [state_name])
		breakpoint
func _goto(state_name: StringName) -> void:
	if _current_state and _states[_current_state].exit: _states[_current_state].exit()
	_current_state = state_name
	if not _current_state: return
	if not _current_state in _states: _add_state(_current_state)
	if _current_state and _states[_current_state].enter: _states[_current_state].enter()
func _process(delta: float) -> void:
	if &"_always_process" in self: (self as Variant)._always_process(delta)
	if _current_state and _states[_current_state].process: _states[_current_state].process(delta)
func _physics_process(delta: float) -> void:
	if &"_always_physics_process" in self: (self as Variant)._always_physics_process(delta)
	if _current_state and _states[_current_state].process: _states[_current_state].physics_process(delta)
#endregion
