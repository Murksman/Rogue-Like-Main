extends Panel

@export var amount_input : LineEdit
@export var img : TextureRect
@export var title : Label

var val : int = 0

func _on_line_edit_focus_exited() -> void:
	val = int(amount_input.text)
	amount_input.text = str(val)

func _on_line_edit_text_submitted(new_text: String) -> void:
	val = int(amount_input.text)
	amount_input.text = str(val)
