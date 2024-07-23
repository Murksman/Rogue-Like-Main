extends GridContainer

@export var weapon_holder : Node2D
@export var inventory_master : Control
@export var slot_resource : Resource

@onready var seperation : Vector2 = Vector2(get_theme_constant("h_separation"), get_theme_constant("v_separation"))
@onready var slot_loaded_res = load(str(slot_resource.resource_path))

var inv_size : Vector2i = Vector2i(1,1)
var inv_size_norm : int = 1
var ref_inv_object : Object

func _gui_input(event):
	if event.is_pressed() || event.is_released():
		var event_pos = floor(event.position / seperation)
		var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
		inventory_master.InventoryInput(event, self, get_child(list_pos))

func _get_drag_data(at_position):
	return self

func _drop_data(at_position, data):
	var event_pos = floor(at_position / seperation)
	var list_pos : int = event_pos.x + (event_pos.y * inv_size.x)
	if data is InventoryItem:
		data.reparent(get_child(list_pos), false)
		
		if data is WeaponItem && data.weapon_object.get_parent() != data:
			var old_index = data.weapon_object.get_parent().slot
			data.weapon_object.reparent(data, false)
			weapon_holder.RemoveWeapon(old_index)
			data.weapon_object.Deselect()

func _can_drop_data(at_position, data):
	return true

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
	
	for i in inv_size_norm:
		var new_slot = slot_loaded_res.instantiate()
		add_child(new_slot)
	
	size = 64 * inv_size
	position = -inv_size / 2
