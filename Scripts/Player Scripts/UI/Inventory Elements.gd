extends Control

@export var inventory_size : Vector2i
@export var slot_size : int
@export var drag_drop_deadzone : float

@onready var inventory = $Inventory

var selected_id : int
var selecting : bool
var drag_drop_mode : bool = false
var clicking : bool = false

var input_temp_slot_selected : int = -1
var click_position : Vector2
var mouse_position : Vector2


func InventoryInput(event):
	mouse_position = get_local_mouse_position()
	if (!selecting && (mouse_position - click_position).length() > drag_drop_deadzone):
		drag_drop_mode = true
	if event.is_action("Primary"):
		if event.is_pressed():
			var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
			input_temp_slot_selected = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
			clicking = true
			click_position = get_local_mouse_position()
		elif event.is_released():
			if (drag_drop_mode):
				var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
				var inventory_list_pos = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
				InventoryItemPlace(inventory_list_pos, selected_id)
				drag_drop_mode = false
			elif (!selecting):
				selecting = true
			clicking = false
		#var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
		#var inventory_list_pos : int = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
		
		#if inventory.get_child(inventory_list_pos) != null:
		#	InventoryItemPlace(inventory_list_pos, selected_id, null)


func InventoryItemPlace(index_to, index_from, item = null):
	inventory.get_child(index_from).get_child(1).visible = false
	inventory.get_child(index_to).get_child(1).visible = true
	selected_id = index_to
	
	drag_drop_mode = false
