extends GridContainer
class_name Inventory

@export var inventory_master : Control

@onready var inv_size : Vector2 = Vector2(columns, ceil(get_child_count() / columns))
@onready var seperation : Vector2 = Vector2(get_theme_constant("h_separation"), get_theme_constant("v_separation"))

func _gui_input(event):
	var event_pos = floor(event.position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	print(get_child(list_pos), list_pos, inv_size, event_pos, event.position)
	inventory_master.InventoryInput(event, self, get_child(list_pos))
	

