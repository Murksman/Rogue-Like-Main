extends Control

@export var edit_xline : LineEdit
@export var edit_yline : LineEdit
@export var prop_title : Label

var val : Vector2i = Vector2i.ZERO

func Update(new_val : Vector2i):
	val = new_val
	edit_xline.text = str(val.x)
	edit_yline.text = str(val.y)

func _on_line_editor_focus_exited() -> void:
	val = Vector2i(int(edit_xline.text), int(edit_yline.text))
	edit_xline.text = str(val.x)
	edit_yline.text = str(val.y)
	$"../../..".Update(self)

func _on_line_editor_text_submitted(new_text: String) -> void:
	edit_xline.release_focus()
	edit_yline.release_focus()
	
	val = Vector2i(int(edit_xline.text), int(edit_yline.text))
	edit_xline.text = str(val.x)
	edit_yline.text = str(val.y)
	$"../../..".Update(self)
