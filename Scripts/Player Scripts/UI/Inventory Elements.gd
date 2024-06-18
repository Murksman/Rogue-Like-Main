extends Control

@export var inventory_size : Vector2i
@export var slot_size : int

@onready var inventory = $Inventory

var selected_id : int
var select : bool

func InventoryInput(event):
	var inventory_vec_pos : Vector2i = (event.position - $Inventory.global_position) / slot_size
	var inventory_list_pos : int = inventory_vec_pos.x + (inventory_vec_pos.y * inventory_size.x)
	
	if inventory.get_child(inventory_list_pos) != null:
		CalcInventory(inventory_list_pos)


func CalcInventory(new_selected):
	inventory.get_child(selected_id).get_child(1).visible = false
	inventory.get_child(new_selected).get_child(1).visible = true
	selected_id = new_selected
