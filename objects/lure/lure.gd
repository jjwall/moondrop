extends CharacterBody2D

@onready var collision = $CollisionShape2D
@onready var anim = $AnimatedSprite2D

var player_ref
var fish_hooked = false
var fish_caught = false
var yanking = false

# var fish_ref ...

# TODO: Lure should handle fishing "minigame"
# TODO: trigger new player input method
# TODO: Clean up trajectory changes.
# TODO: Lure should detect if it's in water or on land, should cancel cast if on land.
# Remove player_ref here, use fish_ref instead

# is_instance_valid(fish_ref)

var target := Vector2()
var lure_path: PackedVector2Array
var lure_t := 0.0
#@onready var ball = $Ball
#@onready var explode_fx = $ExplodeFX
#@onready var blast_fx = $BlastFX

var lure_flying := false
var lure_cast_speed := 1.0
var casting = true

func _ready():
	casting = true
	lure_cast_speed *= randf_range(0.9,1.1)
	#target = Vector2(0,0)
	target += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 32.0
	prep_lure(global_position, target)
	cast()

func player_input_press():
	if fish_hooked:
		fish_caught = true
	else:
		print("cancel cast")

func prep_lure(start_target, end_target):
	var start = start_target
	var end = end_target
	var initial_y_vel: float = -2.0
	var offset_y: float = 0.0
	
	var points = PackedVector2Array()
	lure_t = 0.0
	collision.disabled = true
	
	var n = 100
	for i in range(0,n+1):
		var tx = float(i) / float(n+1)
		var ty = float(i) / float(n)
		var x = lerp(start.x, end.x, tx)
		var y = lerp(start.y, end.y, ty)
		var y_vel = lerp(initial_y_vel, -initial_y_vel, ty)
		points.append(Vector2(x, y+offset_y))
		offset_y += y_vel
	
	points.append(end)
	
	lure_path = points

func _process(delta):
	if not lure_flying:
		return
	
	lure_t += delta * lure_cast_speed
	
	if lure_t >= 1.0:
		if casting:
			on_cast_end()
		else:
			on_cancel_cast_end()
		#ball.visible = false
		#lure_flying = false
		#collision.disabled = false
		#play_plop_in_water_anim()
		#explode_fx.global_position = target
		#explode_fx.emitting = true
		#$Timer.start(1.0)
		#get_node('/root/gameplay/Boss').health -= damage
	else:
		var i = lure_t * float(lure_path.size()-1)
		var a = lure_path[int(i)]
		var b = lure_path[int(i)+1]
		var x = lerp(a, b, i-int(i))
		self.global_position = x

func on_cast_end():
	lure_flying = false
	collision.disabled = false
	play_plop_in_water_anim()

func on_cancel_cast_end():
	lure_flying = false
	self.queue_free()
	
	if fish_caught:
		player_ref._goto("get_item")

func cast():
	#blast_fx.emitting = true
	lure_flying = true
	#ball.visible = true

func yank():
	casting = false
	
	if not yanking:
		yanking = true
		play_idle_anim()
		prep_lure(global_position, player_ref.global_position)
		cast()

func play_bit_anim():
	anim.play("bit")

func play_nibbled_anim():
	anim.play("nibbled")

func play_catching_anim():
	anim.play("catching")
	
func play_plop_in_water_anim():
	anim.play("plop")

func play_idle_anim():
	anim.play("idle")
