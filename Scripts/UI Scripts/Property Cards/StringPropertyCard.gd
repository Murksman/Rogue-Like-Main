extends Control

@export var edit_line : LineEdit
@export var prop_title : Label

var val : String = ""

func _on_line_editor_focus_exited() -> void:
	val = edit_line.text

func _on_line_editor_text_submitted(new_text: String) -> void:
	edit_line.release_focus()
	
	val = edit_line.text
