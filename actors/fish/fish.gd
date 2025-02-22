extends CharacterBody2D

@onready var blackboard: Blackboard = $Blackboard
@onready var lure_seeking_radius: Area2D = $LureSeekingRadius

var fish_type_data: Dictionary

func _ready():
	assert(fish_type_data != {}, "Set fish_type_data for fish instance")
	
	on_spawn()

func on_spawn():
	set_random_angle()
	self.modulate.a = 0
	fade_in()

func set_random_angle():
	self.rotation = randf_range(0, 2 * PI)

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.5)
	tween.play()

func _physics_process(_delta: float) -> void:
	var bodies = lure_seeking_radius.get_overlapping_bodies().filter(func (x): return x.is_in_group("Lures")) 
	blackboard.set_value("lure_objects", bodies)

func play_swim_slow_anim():
	$AnimatedSprite2D.play("swim_slow")
	
func play_swim_fast_anim():
	$AnimatedSprite2D.play("swim_fast")
