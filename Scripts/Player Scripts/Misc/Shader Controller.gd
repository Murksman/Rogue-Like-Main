extends Node2D

func _ready() -> void:
	position = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")) / 2.0
