extends CharacterBody2D

var player_ref

func play_bit_anim():
	$AnimatedSprite2D.play("bit")

func play_nibbled_anim():
	$AnimatedSprite2D.play("nibbled")

func play_catching_anim():
	$AnimatedSprite2D.play("catching")
