extends Node

var commmon_fish_types := [
	{
		"name": "Clown Fish",
		"scene": preload("res://objects/fish_types/clown_fish/clown_fish.tscn"),
		"message": "[rainbow freq=0.5 sat=0.8 val=0.8 speed=1.0][wave amp=50.0 freq=5.0 connected=1]Clown![/wave][/rainbow] Let's turn that frown upside down!",
		"min_weight": 0.22,
		"max_weight": 7.55,
		"buy_price": 100,
		"sell_price": 60,
		"item_type": item_types.FISH,
	},
	{
		"name": "Crab",
		"scene": preload("res://objects/fish_types/crab/crab.tscn"),
		"message": "I was feeling pretty [shake rate=15.0 level=5 connected=1][font_size={38}]crabby...[/font_size][/shake] No wonder I caught this little guy!",
		"min_weight": 1.25,
		"max_weight": 12.72,
		"buy_price": 50,
		"sell_price": 35,
		"item_type": item_types.FISH,
	},
	{
		"name": "Mackerel",
		"scene": preload("res://objects/fish_types/mackerel/mackerel.tscn"),
		"message": "[color=red][font_size={76}]Holy mackerel!!![/font_size][/color] I caught myself a mackerel!",
		"min_weight": 2.22,
		"max_weight": 4.89,
		"buy_price": 40,
		"sell_price": 30,
		"item_type": item_types.FISH,
	},
]

enum item_types {
	FISH,
	ROD,
	BAIT,
	# LURE,
	# etc...
}

enum quest_statuses {
	AVAILABLE,
	ACTIVE,
	COMPLETED,
}
