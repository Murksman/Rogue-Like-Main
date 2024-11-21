extends CanvasLayer

@export var lvl_tilemap_root : Node2D

@onready var player : CharacterBody2D = $"../Player"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		visible = !visible
		player.editor_open = visible
		player.visible = !visible
