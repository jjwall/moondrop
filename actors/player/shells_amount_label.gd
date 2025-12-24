extends Label

@export var shake_duration: float = 0.5
@export var shake_intensity: float = 1.15

var _shake_timer: float = 0.0
var _original_pos: Vector2

func _ready() -> void:
	_original_pos = position

func start_shake():
	_shake_timer = shake_duration
	var modulate_tween = create_tween()
	modulate_tween.tween_property(self, "modulate", Color.RED, 0.25)
	modulate_tween.tween_callback(modulate_white)

func modulate_white():
	create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)

func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		position += offset
	else:
		position = _original_pos
