extends TextureButton

@export var tool_index : int

var pressed_blend_state : float = 0.0


func _on_mouse_entered() -> void:
	get_child(0).visible = true

func _on_mouse_exited() -> void:
	get_child(0).visible = false
