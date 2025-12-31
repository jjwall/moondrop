extends Control

# TODO: Create accept available quest. Can we reuse dialog confirmation feature? -> don't think it's necessary
# TODO: Make actual quests w/ solid dictionary data - abstract classes?
# TODO: Quest Board -> interacting with it brings up quest log AND shows available quests at the top
# TODO: Looking at Quest Log from inventory only shows Active and Completed Quests.
# TODO: Add Melvin / Pop's NPC who stands near Quest Board and has dialog pertaining to quest completion information.
# -> Perhaps he gives starter rod and 5x free starter bait if first time interacting?
# TODO: Update quest mechanics (ex. catch fish, and shows in quest log progress of quest)
# TODO: Turn in quest system (once quest is completed, how do we "turn it in"? -> at quest board I presume>)
# TODO: Add quest completed notification using notification system.
# -> Consider implementing notification "queue" system since we won't want to miss a notification

@onready var quest_log_container: VBoxContainer = %QuestLogContainer

@onready var item_profile_panel: Panel = %ItemProfilePanel
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_description_label: Label = %ItemDescriptionLabel

var quest_log_entry_scene = preload("res://objects/quest_log_entry/quest_log_entry.tscn")
var green_checkmark_icon = preload("res://assets/textures/ui/green-checkmark.png")
var red_exclamation_mark_icon = preload("res://assets/textures/ui/red-exclamation-mark.png")
var yellow_question_mark_icon = preload("res://assets/textures/ui/yellow-question-mark.png")

var quest_data_list = [
	{
		"name": "Catch 3 Big Crabs",
		"description": "Catch 3 big crabs for me.",
		"value": 0,
		"status": RefData.quest_statuses.COMPLETED,
	},
	{
		"name": "Catch 3 Big Crabs",
		"description": "Catch 3 big crabs for me.",
		"value": 0,
		"status": RefData.quest_statuses.COMPLETED,
	},
	{
		"name": "Catch 3 Small Mackerel",
		"description": "Catch 3 sea bass for me.",
		"value": 0,
		"status": RefData.quest_statuses.AVAILABLE,
	},
	{
		"name": "Catch 10 Clown Fish",
		"description": "Catch 3 clown fish for me.",
		"value": 0,
		"status": RefData.quest_statuses.ACTIVE,
	},
	{
		"name": "Catch 10 Clown Fish",
		"description": "Catch 3 clown fish for me.",
		"value": 0,
		"status": RefData.quest_statuses.ACTIVE,
	},
]

func _ready():
	render_quest_log_entries()
	print(item_description_label)

func sort_by_quest_status(a, b):
	return a["status"] < b["status"]

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
					render_quest_status_label("Available Quests:")
			RefData.quest_statuses.ACTIVE:
				if not active_quests_label_rendered:
					active_quests_label_rendered = true
					render_quest_status_label("Active Quests:")
			RefData.quest_statuses.COMPLETED:
				if not completed_quests_label_rendered:
					completed_quests_label_rendered = true
					render_quest_status_label("Completed Quests:")
					
		render_quest_log_entry(quest_data)

func render_quest_status_label(text: String):
	var quest_status_label = Label.new()
	quest_status_label.text = text
	var margin_container = MarginContainer.new()
	margin_container.add_child(quest_status_label)
	#margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_bottom", 12)
	quest_log_container.add_child(margin_container)

func render_quest_log_entry(quest_data: Dictionary):
	var quest_log_entry: Button = quest_log_entry_scene.instantiate()
	quest_log_entry.text = quest_data.name
	quest_log_entry.icon = determine_quest_icon(quest_data.status)
	quest_log_entry.pressed.connect(on_quest_log_entry_pressed.bind(quest_log_entry, quest_data)) # button_down.connect(on_pocket_button_down.bind(item_in_pocket, pocket_index))
	
	var margin_container = MarginContainer.new()
	margin_container.add_child(quest_log_entry)
	margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_bottom", 5)
	quest_log_container.add_child(margin_container)

func on_quest_log_entry_pressed(quest_button: Button, quest_data: Dictionary):
	quest_button.grab_focus()
	render_quest_details(quest_data)

func render_quest_details(quest_data: Dictionary):
	reset_item_details()
	
	item_name_label.text = quest_data.name
	item_description_label.text = quest_data.description
	
	var quest_icon = determine_quest_icon(quest_data.status)
	var quest_icon_sprite = Sprite2D.new()
	quest_icon_sprite.scale.x = 4.5
	quest_icon_sprite.scale.y = 4.5
	quest_icon_sprite.position.x += 60
	quest_icon_sprite.position.y += 60
	quest_icon_sprite.texture = quest_icon
	item_profile_panel.add_child(quest_icon_sprite)

func determine_quest_icon(quest_status: RefData.quest_statuses):
	match quest_status:
		RefData.quest_statuses.AVAILABLE:
			return yellow_question_mark_icon
		RefData.quest_statuses.ACTIVE:
			return red_exclamation_mark_icon
		RefData.quest_statuses.COMPLETED:
			return green_checkmark_icon

func reset_item_details():
	# Wipe previously rendered item profile.
	for child in item_profile_panel.get_children():
		child.queue_free()
		
	item_name_label.text = ""
	item_description_label.text = ""
