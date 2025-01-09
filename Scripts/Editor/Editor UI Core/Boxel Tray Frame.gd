extends Control

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is UIBoxel && get_child_count() == 0

func _drop_data(at_position: Vector2, data: Variant) -> void:
	
