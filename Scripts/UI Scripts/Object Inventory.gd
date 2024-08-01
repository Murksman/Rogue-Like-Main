extends Inventory

@export var inv_background : Control
@export var slot_resource : Resource

@onready var slot_loaded_res = load(str(slot_resource.resource_path))

var inv_size_norm : int = 1
var ref_inv_object : Object


func OpenInventory(target_inventory):
	get_parent().visible = true
	CalcInventory(target_inventory)

func CloseInventory():
	get_parent().visible = false
	for slot in get_children():
		if slot.get_child_count() > 1:
			slot.get_child(1).Recall()
			print("test")

func _drop_data(at_position, data):
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	if data is InventoryItem:
		if data.item_owner && data.item_owner.get_parent() is Chest:
			data.item_owner.get_parent().inventory_items[data.inv_position] = null
		
		data.reparent(get_child(list_pos), false)
		data.item_owner = ref_inv_object.item_container
		data.inv_position = list_pos
		ref_inv_object.inventory_items[list_pos] = data
		
		
		if data is WeaponItem && data.weapon_object.get_parent() != data:
			var old_index = data.weapon_object.get_parent().slot
			data.weapon_object.reparent(data, false)
			weapon_holder.RemoveWeapon(old_index)
			data.weapon_object.Deselect()

func CalcInventory(new_object : Object = null):
	if new_object != null:
		ref_inv_object = new_object
	
	visible = new_object != null
	
	inv_size = ref_inv_object.inventory_size
	
	if inv_size_norm != inv_size.x * inv_size.y:
		inv_size_norm = inv_size.x * inv_size.y
		
		for child in get_children():
			remove_child(child)
			child.queue_free()
		
		columns = inv_size.x
		
		for i in inv_size_norm:
			var new_slot = slot_loaded_res.instantiate()
			add_child(new_slot)
			new_slot.name = "Slot" + str(i)
		
		size = 64 * inv_size
		position = -inv_size * 32
		inv_background.position = position
		inv_background.size = size
		inv_background.get_child(0).texture.width = size.x
		inv_background.get_child(0).texture.height = size.y
	
	var slot_number = 0
	
	for new_item in new_object.inventory_items:
		if new_item == null: continue
		
		new_item.reparent(get_child(slot_number), false)

