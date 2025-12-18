extends Node2D
var target

func _ready() -> void:
	process_mode =Node.PROCESS_MODE_ALWAYS

func set_target(_target):
	target = _target
	global_position = target.global_position
	global_position.x -= 480
	global_position.y -= 354

func _process(_delta):
	global_position = target.global_position
	global_position.x -= 480
	global_position.y -= 354
