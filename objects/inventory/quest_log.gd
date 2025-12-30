extends Control

@onready var quest_log_container: VBoxContainer = %QuestLogContainer

var quest_log_entry_scene = preload("res://objects/quest_log_entry/quest_log_entry.tscn")
var green_checkmark_icon = preload("res://assets/textures/ui/green-checkmark.png")
var red_exclamation_mark_icon = preload("res://assets/textures/ui/red-exclamation-mark.png")
var yellow_question_mark_icon = preload("res://assets/textures/ui/yellow-question-mark.png")

var quest_data_list = [
	{
		"name": "Catch 3 Big Crabs",
		"icon": "",
		"description": "Catch 3 big crabs for me.",
		#"completed": false,
		"value": 0,
		"status": RefData.quest_statuses.COMPLETED,
	},
	{
		"name": "Catch 3 Small Mackerel",
		"icon": "",
		"description": "Catch 3 sea bass for me.",
		#"completed": false,
		"value": 0,
		"status": RefData.quest_statuses.AVAILABLE,
	},
	{
		"name": "Catch 10 Clown Fish",
		"icon": "",
		"description": "Catch 3 clown fish for me.",
		#"completed": false,
		"value": 0,
		"status": RefData.quest_statuses.ACTIVE,
	},
]

func _ready():
	render_quest_log_entries()

func render_quest_log_entries():
	quest_data_list.sort_custom(sort_by_quest_status)
	var available_quests_label_rendered = false
	var active_quests_label_rendered = false
	var completed_quests_label_rendered = false
	
	for quest_data in quest_data_list:
		match quest_data.status:
			RefData.quest_statuses.AVAILABLE:
				if not available_quests_label_rendered:
					available_quests_label_rendered = true
					var new_label = Label.new()
					new_label.text = "Available Quests:"
					quest_log_container.add_child(new_label)
			RefData.quest_statuses.ACTIVE:
				if not active_quests_label_rendered:
					active_quests_label_rendered = true
					var new_label = Label.new()
					new_label.text = "Active Quests:"
					quest_log_container.add_child(new_label)
			RefData.quest_statuses.COMPLETED:
				if not completed_quests_label_rendered:
					completed_quests_label_rendered = true
					var new_label = Label.new()
					new_label.text = "Completed Quests:"
					quest_log_container.add_child(new_label)
					
		render_quest_log_entry(quest_data)

func sort_by_quest_status(a, b):
	return a["status"] < b["status"]

func render_quest_log_entry(quest_data: Dictionary):
	var quest_log_entry: Button = quest_log_entry_scene.instantiate()
	quest_log_entry.text = quest_data.name
	
	match quest_data.status:
		RefData.quest_statuses.AVAILABLE:
			quest_log_entry.icon = yellow_question_mark_icon
		RefData.quest_statuses.ACTIVE:
			quest_log_entry.icon = red_exclamation_mark_icon
		RefData.quest_statuses.COMPLETED:
			quest_log_entry.icon = green_checkmark_icon
	
	quest_log_container.add_child(quest_log_entry)
