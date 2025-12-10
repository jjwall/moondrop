extends Node2D

#@onready var camera_shake: CameraShake = $Player/Camera2D/CameraShake
var fish_group: Node2D

func _ready() -> void:
	fish_group = $FishGroup

# Called in the fish_spawn_area.gd script
func add_fish_to_group(fish: Node2D):
	fish_group.call_deferred("add_child", fish)

#func _on_bouncing_character_body_2d_bounce(collision: KinematicCollision2D) -> void:
	##camera_shake.apply_impulse(Vector2.from_angle(randf_range(0, TAU)) * 2000)
	#camera_shake.rumble(50, 0.25)
