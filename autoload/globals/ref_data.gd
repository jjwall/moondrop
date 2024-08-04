extends Node

var commmon_fish_types := [
	{
		"name": "Clown Fish",
		"scene": preload("res://objects/fish_types/clown_fish/clown_fish.tscn"),
		"message": "Clown! Let's turn that frown upside down!",
		"min_weight": 0.22,
		"max_weight": 7.55,
	},
	{
		"name": "Crab",
		"scene": preload("res://objects/fish_types/crab/crab.tscn"),
		"message": "I was feeling pretty crabby... No wonder I caught this little guy!",
		"min_weight": 1.25,
		"max_weight": 12.72,
	}
]
