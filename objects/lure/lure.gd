extends CharacterBody2D

var player_ref
var fish_hooked = false
# var fish_ref ...

# TODO: Lure should handle fishing "minigame"
# TODO: trigger new player input method
# Remove player_ref here, use fish_ref instead

# is_instance_valid(fish_ref)

func play_bit_anim():
	$AnimatedSprite2D.play("bit")

func play_nibbled_anim():
	$AnimatedSprite2D.play("nibbled")

func play_catching_anim():
	$AnimatedSprite2D.play("catching")







func player_input_press():
	pass
	# if fish_hooked do blah
	# if not, scare fish away
