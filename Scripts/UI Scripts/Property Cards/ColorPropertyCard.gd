extends Control

@export var edit_color : ColorPickerButton
@export var prop_title : Label

var val : Color = Color.WHITE

func Update(new_val : Color):
	val = new_val
	edit_color.color = val


func _on_color_picker_button_color_changed(color: Color) -> void:
	val = color
	$"../../..".Update(self)
