extends CharacterBody2D

@onready var collision = $CollisionShape2D

var player_ref
var fish_hooked = false

# var fish_ref ...

# TODO: Lure should handle fishing "minigame"
# TODO: trigger new player input method
# TODO: Clean up trajectory changes.
# TODO: Lure should detect if it's in water or on land, should cancel cast if on land.
# Remove player_ref here, use fish_ref instead

# is_instance_valid(fish_ref)

var target := Vector2()
var ball_path: PackedVector2Array
var ball_t := 0.0
#@onready var ball = $Ball
#@onready var explode_fx = $ExplodeFX
#@onready var blast_fx = $BlastFX

var ball_flying := false
var ball_speed := 1.0

func _ready():
	#ball.visible = false
	collision.disabled = true
	ball_speed *= randf_range(0.9,1.1)
	
	#target = Vector2(0,0)
	target += Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 32.0
	var start = global_position
	var end = target
	var initial_y_vel: float = -2.0
	var offset_y: float = 0.0
	
	var points = PackedVector2Array()
	
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
	
	ball_path = points
	
	blast()

func _process(delta):
	if not ball_flying:
		return
	
	ball_t += delta * ball_speed
	
	if ball_t >= 1.0:
		#ball.visible = false
		ball_flying = false
		collision.disabled = false
		play_nibbled_anim() # TODO: Add land_in_water_anim()
		#explode_fx.global_position = target
		#explode_fx.emitting = true
		#$Timer.start(1.0)
		#get_node('/root/gameplay/Boss').health -= damage
	else:
		var i = ball_t * float(ball_path.size()-1)
		var a = ball_path[int(i)]
		var b = ball_path[int(i)+1]
		var x = lerp(a, b, i-int(i))
		self.global_position = x

func play_bit_anim():
	$AnimatedSprite2D.play("bit")

func play_nibbled_anim():
	$AnimatedSprite2D.play("nibbled")

func play_catching_anim():
	$AnimatedSprite2D.play("catching")

func blast():
	#blast_fx.emitting = true
	ball_flying = true
	#ball.visible = true






func player_input_press():
	pass
	# if fish_hooked do blah
	# if not, scare fish away
