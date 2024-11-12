extends Control

func _input(event: InputEvent) -> void:
	print("_input() event: ", event)


func _gui_input(event: InputEvent) -> void:
	print("_gui_input() event: ", event)
