extends Inventory

class_name WeaponLoadout

func _can_drop_data(at_position, data):
	return data is WeaponItem && data.weapon_object != null


func _drop_data(at_position, data):
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	if data is InventoryItem:
		if data.item_owner is Chest:
			data.item_owner.inventory_items[data.inv_position] = null
		
		data.reparent(get_child(list_pos), false)
		data.item_owner = self
		data.inv_position = list_pos
		
		if data is WeaponItem:
			data.weapon_object.reparent(weapon_holder.get_child(list_pos), false)
			weapon_holder.AddWeapon(true, list_pos)

