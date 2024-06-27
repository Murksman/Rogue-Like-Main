extends GridContainer
class_name Inventory

@export var inventory_master : Control

@onready var inv_size : Vector2 = Vector2(columns, ceil(get_child_count() / columns))
@onready var seperation : Vector2 = Vector2(get_theme_constant("h_separation"), get_theme_constant("v_separation"))

func _gui_input(event):
	if event.is_pressed() || event.is_released():
		var event_pos = floor(event.position / seperation)
		var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
		inventory_master.InventoryInput(event, self, get_child(list_pos))

func _get_drag_data(at_position):
	return self

func _drop_data(at_position, data):
	#print(name)
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	#print(is_drag_successful(), data is InventoryItem)
	if data is InventoryItem:
		print("test", data)
		data.reparent(get_child(list_pos), false)
		data.owner = get_tree().edited_scene_root
		var test = data.get_parent()
		#print(data.get_parent(), data.global_position)
		#print(data.get_parent().get_parent().name)

func _can_drop_data(at_position, data):
	return true
