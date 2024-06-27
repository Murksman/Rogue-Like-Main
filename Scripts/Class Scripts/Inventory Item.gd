extends TextureRect

class_name InventoryItem

func _init(input_area : Vector2 = Vector2(40,40)):
	position = Vector2(12,12)
	size = input_area
	modulate.a = 1
	print("test")

func _gui_input(event : InputEvent):
	$"../..".inventory_master.ItemInput(event, $"../..", self)


func _get_drag_data(at_position):
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.modulate = self.modulate
	preview.modulate.a = 0.4
	set_drag_preview(preview)
	return self

func _can_drop_data(at_position, data):
	return true

func _drop_data(at_position, data):
	if is_drag_successful() && data != self && data is InventoryItem && false: 
		print(data)
		var grid_pos = floor(at_position / $"../..".seperation)
		var list_pos : int = grid_pos.x + (grid_pos.y * $"../..".inv_size.x)
		print(get_child(list_pos), list_pos, $"../..".inv_size, grid_pos, at_position)
		$"../..".inventory_master.DropDrag(data, $"../..", get_parent())
