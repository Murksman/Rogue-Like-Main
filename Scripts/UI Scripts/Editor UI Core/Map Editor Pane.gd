extends Control

@export var editor_overlay : CanvasLayer

func _gui_input(event: InputEvent) -> void:
	editor_overlay.LevelPanePressed(event)
