extends Node2D

@onready var cam = $"../../../Main Plane Controller/Main Plane/Player/Camera2D"

func _process(delta):
	global_position = cam.global_position
	$"Player Dopple Cam".offset = cam.offset
