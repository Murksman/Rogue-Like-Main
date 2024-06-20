extends Control

@export var inventory_size : Vector2i
@export var slot_size : int
@export var drag_drop_deadzone : float

@onready var inventory = $Inventory

var selected_id : int = -1
var drag_drop_mode : int = 0
var clicking : bool = false

var click_position : Vector2
var mouse_position : Vector2


func InventoryInput(event):
	mouse_position = get_local_mouse_position()
	
	if (drag_drop_mode == 0 && clicking && (mouse_position - click_position).length() > drag_drop_deadzone):
		drag_drop_mode = 2
	
	if event.is_action("Primary"):
		var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
		var inventory_list_pos : int = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
		
		clicking = event.is_pressed()
		
		if clicking:
			if (drag_drop_mode == 1):
				if InventoryItemPlace(inventory_list_pos, selected_id):
					drag_drop_mode = -1
			elif inventory.get_child(inventory_list_pos) != null && inventory.get_child(inventory_list_pos).get_child(1) != null:
				click_position = get_local_mouse_position()
				selected_id = inventory_list_pos
		else:
			if (drag_drop_mode == 2):
				InventoryItemPlace(inventory_list_pos, selected_id)
				drag_drop_mode = 0
			elif (drag_drop_mode == 0):
				drag_drop_mode = 1
			elif (drag_drop_mode == -1):
				drag_drop_mode = 0
		#var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
		#var inventory_list_pos : int = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
		
		#if inventory.get_child(inventory_list_pos) != null:
		#	InventoryItemPlace(inventory_list_pos, selected_id, null)


func InventoryItemPlace(index_to, index_from):
	var slot_exists = inventory.get_child(index_to) != null
	var target_slot_empty = slot_exists && inventory.get_child(index_to).get_child(1) == null
	
	if slot_exists && target_slot_empty:
		var selected_item : Node = inventory.get_child(index_from).get_child(1)
		if selected_item != null:
			selected_item.reparent(inventory.get_child(index_to), false)
			selected_item.global_position = inventory.get_child(index_to).global_position
	
	return slot_exists && target_slot_empty
