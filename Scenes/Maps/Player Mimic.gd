extends Node2D

@onready var player = $"../../../Main Plane Controller/Main Plane/Player"

func _process(delta):
	global_position = player.global_position
