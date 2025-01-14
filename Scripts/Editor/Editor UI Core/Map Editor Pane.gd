extends Control

@export var editor_overlay : CanvasLayer

func _gui_input(event: InputEvent) -> void:
	print("pane pressed")
	editor_overlay.LevelPanePressed(event)
