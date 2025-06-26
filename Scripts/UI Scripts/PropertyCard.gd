extends Control

@export var edit_line : LineEdit
@export var prop_value : Label
@export var prop_title : Label

var val : int = 0

func _on_line_editor_focus_entered() -> void:
	prop_value.visible = false


func _on_line_editor_focus_exited() -> void:
	prop_value.visible = true
	
	if edit_line.text.is_valid_float():
		val = int(edit_line.text)
		prop_value.text = str(val)

func _on_line_editor_text_submitted(new_text: String) -> void:
	prop_value.visible = true
	
	edit_line.release_focus()
	
	if edit_line.text.is_valid_float():
		val = int(edit_line.text)
		prop_value.text = str(val)
