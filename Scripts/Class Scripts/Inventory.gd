extends GridContainer
class_name Inventory

@export var weapon_holder : Node2D
@export var inventory_master : Control

@onready var inv_size : Vector2 = Vector2(columns, ceil(get_child_count() / columns))
@onready var seperation : Vector2 = Vector2(get_theme_constant("h_separation"), get_theme_constant("v_separation"))

#func _gui_input(event):
	#if event.is_pressed() || event.is_released():
		#var event_pos = floor(event.position / seperation)
		#var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
		#inventory_master.InventoryInput(event, self, get_child(list_pos))

func _get_drag_data(at_position):
	return self


func _drop_data(at_position, data):
	DropElement(data, at_position)
	ReparentWeapon(data)


func DropElement(data, at_position):
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	if data is InventoryItem:
		if data.item_owner && data.item_owner.get_parent() is Chest:
			data.item_owner.get_parent().inventory_items[data.inv_position] = null
		
		var data_parent = data.get_parent().get_parent()
		
		data.reparent(get_child(list_pos), false)
		data.item_owner = get_child(list_pos)
		data.inv_position = list_pos
		
		if data_parent is ObjectInventory: 
			data_parent.ref_inv_object.RecalculateContent()
			#print(data_parent.ref_inv_object.inventory_items)


func ReparentWeapon(data):
	if data is WeaponItem && data.weapon_object != null && data.weapon_object.get_parent() != data:
		var old_index = data.weapon_object.get_parent().slot
		data.weapon_object.reparent(data, false)
		weapon_holder.RemoveWeapon(old_index)
		data.weapon_object.Deselect()

func _can_drop_data(at_position, data):
	return data is InventoryItem


func WipeInventory():
	for slot in get_children():
		for item in slot.get_children():
			if not item is InventoryItem: continue
			item.queue_free()
