extends Control

@export var edit_line : LineEdit
@export var prop_title : Label

var val : int = 0

func Update(new_val : int):
	val = new_val
	edit_line.text = str(val)

func _on_line_editor_focus_exited() -> void:
	val = int(edit_line.text)
	edit_line.text = str(val)
	$"../../..".Update(self)

func _on_line_editor_text_submitted(new_text: String) -> void:
	edit_line.release_focus()
	
	val = int(edit_line.text)
	edit_line.text = str(val)
	$"../../..".Update(self)
