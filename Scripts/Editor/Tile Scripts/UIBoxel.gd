extends Control
class_name UIBoxel

@onready var tile_highlighter : Control = $"Tile Select Outline"
@onready var name_label : Control = $"Tile Display/Name Label"

@export var boxel : Boxel

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: $"..".HoverTile(self)
	if event.is_action_pressed("Primary"):
		$"..".SelectTile(self)



func _on_mouse_exited() -> void:
	$"..".MouseExit(self)
