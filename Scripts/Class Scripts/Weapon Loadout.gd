extends Inventory

class_name WeaponLoadout

func _can_drop_data(at_position, data):
	return data is WeaponItem && data.weapon_object != null

"""
func _gui_input(event):
	if event.is_pressed() || event.is_released():
		var event_pos = floor(event.position / seperation)
		var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
		inventory_master.InventoryInput(event, self, get_child(list_pos))

func _get_drag_data(at_position):
	pass
"""

func _drop_data(at_position, data):
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	if data is InventoryItem:
		data.reparent(get_child(list_pos), false)
		
		if data is WeaponItem:
			data.weapon_object.reparent(weapon_holder.get_child(list_pos), false)
			weapon_holder.AddWeapon(true, list_pos)
		
		return

