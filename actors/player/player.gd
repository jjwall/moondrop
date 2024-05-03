extends CharacterBody2D

const SPEED = 300.0
var anim: AnimatedSprite2D
var direction = Vector2(0, 0)

func _ready():
	anim = $AnimatedSprite2D
	_goto("idle_front")

func _always_process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		_goto("walk_left")
	#if Input.is_action_just_released("ui_left"):
		#_goto("idle_left")
	if Input.is_action_just_pressed("ui_right"):
		_goto("walk_right")
	#if Input.is_action_just_released("ui_right"):
		#_goto("idle_right")
	if Input.is_action_just_pressed("ui_down"):
		_goto("walk_front")
	#if Input.is_action_just_released("ui_down"):
		#_goto("idle_front")
	if Input.is_action_just_pressed("ui_up"):
		_goto("walk_back")
	#if Input.is_action_just_released("ui_up"):
		#_goto("idle_back")
	#else:
		#move_toward(velocity.x, 0, SPEED)

func _always_physics_process(_delta):		
	var direction := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity = direction * SPEED
	
	move_and_slide()

#region State idle_front
func _state_idle_front_enter():
	direction = Vector2(0, 0)
	anim.play("idle_front")

#func _state_idle_front_process(_delta):
	#print("hellooo")
##
#func _state_idle_front_physics_process(_delta):
	#print("hiiiii")
#
#func _state_idle_front_exit():
	#print("helloooo")
#endregion

#region State walk_front
func _state_walk_front_enter():
	anim.play("walk_front")
	
func _state_walk_front_process(_delta):
	if Input.is_action_just_released("ui_down") and (not Input.is_action_pressed("ui_left") or not Input.is_action_pressed("ui_right")):
		_goto("idle_front")
#endregion

#region State idle_back
func _state_idle_back_enter():
	anim.play("idle_back")
#endregion

#region State walk_back
func _state_walk_back_enter():
	anim.play("walk_back")

func _state_walk_back_process(_delta):
	if Input.is_action_just_released("ui_up") and (not Input.is_action_pressed("ui_left") or not Input.is_action_pressed("ui_right")):
		_goto("idle_back")
#endregion

#region State idle_right
func _state_idle_right_enter():
	anim.play("idle_side")
	anim.flip_h = true
#endregion

#region State walk_right
func _state_walk_right_enter():
	anim.play("walk_side")
	anim.flip_h = true

func _state_walk_right_process(_delta):
	if Input.is_action_just_released("ui_right") and (not Input.is_action_pressed("ui_up") or not Input.is_action_pressed("ui_down")):
		_goto("idle_right")
#endregion

#region State idle_left
func _state_idle_left_enter():
	anim.play("idle_side")
	anim.flip_h = false
#endregion

#region State walk_left
func _state_walk_left_enter():
	anim.play("walk_side")
	anim.flip_h = false

func _state_walk_left_process(_delta):
	if Input.is_action_just_released("ui_left") and (not Input.is_action_pressed("ui_up") or not Input.is_action_pressed("ui_down")):
		_goto("idle_left")
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
