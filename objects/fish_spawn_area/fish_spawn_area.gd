extends Node2D

#@export var area_height = 125
#@export var area_width = 850

var fish_scene = preload("res://actors/fish/fish.tscn")

@export var max_fish_count = 4
var current_fish_count = 0
var area: CollisionShape2D
var origin_x: float
var origin_y: float
var extent_x: float
var extent_y: float

var fish_list: Array[Node2D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area = $Area2D/CollisionShape2D
	#area.size.x = area_width
	#area.size.y = area_width
	origin_x = area.global_position.x - area.shape.size.x / 2
	origin_y = area.global_position.y - area.shape.size.y / 2
	extent_x = area.global_position.x + area.shape.size.x / 2
	extent_y = area.global_position.y + area.shape.size.y / 2
	#spawn_fish()

func spawn_fish() -> Node2D:
	# Get random position within the spawn area.
	var x = randf_range(origin_x, extent_x)
	var y = randf_range(origin_y, extent_y)
	
	var new_pos = Vector2(x, y)
	var new_fish = fish_scene.instantiate()
	new_fish.set_position(new_pos)
	#utils.main_node.call_deferred("add child", bullet)
	self.get_parent().call_deferred("add_child", new_fish)
	
	return new_fish

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if fish_list.size() < max_fish_count:
		var fish = spawn_fish()
		fish_list.append(fish)
