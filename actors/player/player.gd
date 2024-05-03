extends CharacterBody2D

const SPEED = 300.0
var anim: AnimatedSprite2D
var direction := Vector2.ZERO
var prev_direction := Vector2(0, 1)

func _ready():
	anim = $AnimatedSprite2D
	_goto("idle")

func _always_process(_delta):
	direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	if direction == Vector2(0,0):
		_goto("idle")
	else:
		_goto("walk")

func _always_physics_process(_delta):
	velocity = direction * SPEED
	
	move_and_slide()

#region State idle
func _state_idle_enter():
	match prev_direction:
		Vector2.DOWN:
			anim.play("idle_front")
		Vector2.UP:
			anim.play("idle_back")
		Vector2.RIGHT:
			anim.play("idle_side")
		Vector2.LEFT:
			anim.play("idle_side")
		Vector2(-1, 1):
			anim.play("idle_side")
		Vector2(1, 1):
			anim.play("idle_side")
		Vector2(-1, -1):
			anim.play("idle_side")
		Vector2(1, -1):
			anim.play("idle_side")

func _state_idle_process(_delta):
	pass

func _state_idle_physics_process(_delta):
	pass

func _state_idle_exit():
	pass
#endregion

#region State walk
func _state_walk_enter():
	match direction:
		Vector2.DOWN:
			anim.play("walk_front")
		Vector2.UP:
			anim.play("walk_back")
		Vector2.RIGHT:
			anim.play("walk_side")
			anim.flip_h = true
		Vector2.LEFT:
			anim.play("walk_side")
			anim.flip_h = false
		Vector2(-1, 1):
			anim.play("walk_side")
			anim.flip_h = false
		Vector2(1, 1):
			anim.play("walk_side")
			anim.flip_h = true
		Vector2(-1, -1):
			anim.play("walk_side")
			anim.flip_h = false
		Vector2(1, -1):
			anim.play("walk_side")
			anim.flip_h = true
	
	prev_direction = direction
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
