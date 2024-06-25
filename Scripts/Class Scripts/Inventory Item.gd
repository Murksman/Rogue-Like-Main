extends ColorRect

class_name InventoryItem

func _init(input_area : Vector2 = Vector2(40,40)):
	position = Vector2(12,12)
	size = input_area
	color.a = 1
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event : InputEvent):
	$"../..".inventory_master.ItemInput(event, $"../..", self)
