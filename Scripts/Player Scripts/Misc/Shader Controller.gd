extends Node2D

func _ready() -> void:
	position = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")) / 2.0

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#global_position = $"../..".global_position
