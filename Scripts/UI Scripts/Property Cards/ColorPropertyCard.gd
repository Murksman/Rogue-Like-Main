extends Control

@export var edit_color : ColorPickerButton
@export var prop_title : Label

var val : Color = Color.WHITE

func _on_color_picker_button_color_changed(color: Color) -> void:
	val = color
