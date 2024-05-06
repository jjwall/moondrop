@tool
extends Sprite2D

func calculate_aspect_ratio():
	print("hiiiiii")
	material.set_shader_param("aspect_ratio", scale.y / scale.x)



func _on_item_rect_changed():
	print("hiiii")
