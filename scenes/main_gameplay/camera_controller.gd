extends Node2D
var target
var camera_follow = true

func _ready() -> void:
	process_mode =Node.PROCESS_MODE_ALWAYS

func set_fixed_camera_position():
	#global_position.x -= 480
	global_position.y -= 220

func set_target(_target):
	if camera_follow:
		target = _target
		global_position = target.global_position
		global_position.x -= 480
		global_position.y -= 354

func _process(_delta):
	if camera_follow:
		global_position = target.global_position
		global_position.x -= 480
		global_position.y -= 354
