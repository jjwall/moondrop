@tool
extends Area2D

var fish_scene = preload("res://actors/fish/fish.tscn")

@export var max_fish_count = 4
@export var fish_spawner_wait_time = 15
@export_enum("Common", "Uncommon", "Rare") var fish_spawn_area_type: int

@onready var fish_spawner_timer = $FishSpawnerTimer

var spawn_area: CollisionShape2D
var origin_x: float
var origin_y: float
var extent_x: float
var extent_y: float

var fish_list: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		fish_spawner_timer.wait_time = fish_spawner_wait_time
		fish_spawner_timer.start()
		
		spawn_area = self.find_children("*", "CollisionShape2D")[0]
		origin_x = spawn_area.global_position.x - spawn_area.shape.size.x / 2
		origin_y = spawn_area.global_position.y - spawn_area.shape.size.y / 2
		extent_x = spawn_area.global_position.x + spawn_area.shape.size.x / 2
		extent_y = spawn_area.global_position.y + spawn_area.shape.size.y / 2

func spawn_fish() -> Node2D:
	# Get random position within the spawn area.
	var x = randf_range(origin_x, extent_x)
	var y = randf_range(origin_y, extent_y)

	var new_pos = Vector2(x, y)
	var new_fish = fish_scene.instantiate()
	
	# Set random common fish type.
	new_fish.fish_type_data = get_random_fish_type()
	
	new_fish.set_position(new_pos)
	self.get_parent().add_fish_to_group(new_fish)
	
	return new_fish

# TODO: Add uncommon and rare fish types and add getters for them here.
func get_random_fish_type() -> Dictionary:
	if fish_spawn_area_type == 0:
		var index = randi_range(0, RefData.commmon_fish_types.size() - 1)
		return RefData.commmon_fish_types[index]
	elif fish_spawn_area_type == 1:
		assert(fish_spawn_area_type != 0, "Add uncommon fish types to ref data!")
		print("*** Add uncommon fish types to ref data! ***")
		print("*** CHANGE CODE IN get_random_fish_type() func in fish_spawn_area.gd")
		var index = randi_range(0, RefData.commmon_fish_types.size() - 1)
		return RefData.commmon_fish_types[index]
	else:
		assert(fish_spawn_area_type != 0, "Add rare fish types to ref data!")
		print("*** Add rare fish types to ref data! ***")
		print("*** CHANGE CODE IN get_random_fish_type() func in fish_spawn_area.gd")
		var index = randi_range(0, RefData.commmon_fish_types.size() - 1)
		return RefData.commmon_fish_types[index]

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings():
	var collision_shape_children = self.find_children("*", "CollisionShape2D")
	
	if collision_shape_children.size() < 1:
		return ["Add a RectangleShape2D collision shape to define the spawn area's dimensions."]
	elif collision_shape_children[0].shape is not RectangleShape2D:
		return ["Collision shape should be a RectangleShape2D."]
	else:
		return []

func attempt_to_spawn_fish():
	# Remove any fish entries that have already been caught or ran away,
	check_and_remove_invalid_fish_entries()
	
	# Spawn a fish at random time intervals for the same of immersion.
	var random_spawn_chance = randi_range(1, 3)
	if random_spawn_chance == 3:
		if fish_list.size() < max_fish_count:
			var fish = spawn_fish()
			fish_list.append(fish)

func check_and_remove_invalid_fish_entries():
	var index_to_remove = -1
	
	for i in fish_list.size():
		if !is_instance_valid(fish_list[i]):
			index_to_remove = i
	
	if index_to_remove > -1:
		fish_list.remove_at(index_to_remove)

func _on_fish_spawn_timer_timeout() -> void:
	attempt_to_spawn_fish()
