extends Node2D

@onready var player = %Player

var basic_rod_scene = preload("res://objects/rod_types/basic_rod/basic_rod.tscn")

func _ready() -> void:
	player.anim.play("idle_north")
	$CameraController.camera_follow = false
	$CameraController.set_fixed_camera_position()

func interact():
	player.anim.play("idle_south")
	Globals.recent_exit_location = Globals.ExitLocations.SHOP_EXIT
	SceneGirl.change_scene("res://scenes/main_gameplay/main_gameplay.tscn")
