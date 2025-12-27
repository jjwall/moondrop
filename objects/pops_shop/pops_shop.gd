extends StaticBody2D

@onready var player = %Player

func interact():
	player.anim.play("idle_north")
	SceneGirl.change_scene("res://scenes/item_shop/item_shop.tscn")
