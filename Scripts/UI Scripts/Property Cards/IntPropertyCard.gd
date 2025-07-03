extends Control

@export var edit_line : LineEdit
@export var prop_title : Label

var val : float = 0

func _on_line_editor_focus_exited() -> void:
	val = float(edit_line.text)
	edit_line.text = str(val)

func _on_line_editor_text_submitted(new_text: String) -> void:
	edit_line.release_focus()
	
	val = float(edit_line.text)
	edit_line.text = str(val)
