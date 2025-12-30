extends Control

@onready var quest_log_container: VBoxContainer = %QuestLogContainer

var quest_log_entry_scene = preload("res://objects/quest_log_entry/quest_log_entry.tscn")

var quest_list = [
	{
		"name": "Daily Quest",
		"icon": "",
		"description": "Catch 3 big crabs for me.",
		"completed": false,
		"value": 0,
	},
]

func _ready():
	for i in range(12):
		if i == 0:
			var new_label = Label.new()
			new_label.text = "Active Quests:"
			quest_log_container.add_child(new_label)
		if i == 5:
			var new_label = Label.new()
			new_label.text = "Completed Quests:"
			quest_log_container.add_child(new_label)
		render_quest_log_entry()

func render_quest_log_entry():
	var quest_log_entry = quest_log_entry_scene.instantiate()
	print("hello?")
	#var pos = quest_log_container.global_position
	#pos.x += 48
	#pos.y += 48
	#quest_log_entry.position.y += 50
	#item_profile.scale.x *= 1.5
	#item_profile.scale.y *= 1.5
	#quest_log_entry.set_position(pos)
	quest_log_container.add_child(quest_log_entry)
