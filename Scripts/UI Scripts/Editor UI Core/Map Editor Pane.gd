extends Control

@export var editor_overlay : CanvasLayer

func _gui_input(event: InputEvent) -> void:
	if event.is_action("Editor Primary"):
		if event.is_pressed():
			editor_overlay.LevelPanePressed(event)
