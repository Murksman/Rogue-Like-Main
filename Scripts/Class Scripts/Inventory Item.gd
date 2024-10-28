extends TextureRect

class_name InventoryItem

var item_owner : Node
@export var inv_position : int

func _init(input_area : Vector2 = Vector2(40,40)):
	position = Vector2(12,12)
	size = input_area
	modulate.a = 1
	item_owner = get_parent()

#func _gui_input(event : InputEvent):
	#$"../..".inventory_master.ItemInput(event, $"../..", self)


func _get_drag_data(at_position):
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.modulate = self.modulate
	preview.modulate.a = 0.4
	set_drag_preview(preview)
	return self

func _can_drop_data(at_position, data):
	return true

func Recall():
	reparent(item_owner, false)
