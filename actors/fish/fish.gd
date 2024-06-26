extends CharacterBody2D
@onready var blackboard: Blackboard = $Blackboard
@onready var lure_seeking_radius: Area2D = $LureSeekingRadius

func _physics_process(_delta: float) -> void:
	var bodies = lure_seeking_radius.get_overlapping_bodies().filter(func (x): return x.is_in_group("Lures")) 
	blackboard.set_value("lure_objects", bodies)

func play_swim_slow_anim():
	$AnimatedSprite2D.play("swim_slow")
	
func play_swim_fast_anim():
	$AnimatedSprite2D.play("swim_fast")
