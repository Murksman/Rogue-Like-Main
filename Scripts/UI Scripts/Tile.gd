extends Control
class_name Tile

@onready var tile_highlighter : Control = $"Tile Select Outline"

var layer : int = 0

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Primary"):
		$"..".SelectTile(self)
