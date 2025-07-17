extends Control

@export var tile_highlighter : Control
@export var boxel_res_path : String

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: LevelInfo.editor_ref.HoverBoxel(self)
	if event.is_action_pressed("Primary") && event is InputEventMouseButton:
		LevelInfo.editor_ref.SelectBoxel(self)
