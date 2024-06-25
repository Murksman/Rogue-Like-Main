extends Control

@export var inventory_size : Vector2i
@export var slot_size : int
@export var drag_drop_deadzone : float

var selected_id : int = -1
var drag_drop_mode : int = 0
var clicking : bool = false

var click_position : Vector2
var mouse_position : Vector2

var temp_hold_item : Control
var mouse_hold_item : Control

func InventoryLogic(event : InputEvent, inventory_ref : Inventory, input_slot : Control):
	MouseChange()
	
	if mouse_hold_item != null:
		if Input.is_action_pressed("Primary"): 
			mouse_hold_item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			mouse_hold_item.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if event.is_action("Primary"):
		clicking = event.is_pressed()
		
		if clicking:
			if (drag_drop_mode == 1):
				drag_drop_mode = -1
				PlaceItem(input_slot)
			else:
				click_position = get_local_mouse_position()
				temp_hold_item = input_slot.get_child(1)
		else:
			if (drag_drop_mode == 2):
				drag_drop_mode = 0
				PlaceItem(input_slot)
			elif (drag_drop_mode == 0 && temp_hold_item != null):
				drag_drop_mode = 1
				mouse_hold_item = temp_hold_item
			elif (drag_drop_mode == -1):
				drag_drop_mode = 0
	
	print(drag_drop_mode, " ", temp_hold_item, " ", mouse_hold_item)

func ItemInput(event : InputEvent, inventory_ref : Inventory, input_item : InventoryItem):
	InventoryLogic(event, inventory_ref, input_item.get_parent())

func InventoryInput(event : InputEvent, inventory_ref : Inventory, event_item_slot):
	InventoryLogic(event, inventory_ref, event_item_slot)

func BackGroundInput(event : InputEvent):
	MouseChange()
	
	if event.is_action_pressed("Primary") && drag_drop_mode == 1:
		drag_drop_mode = -1
		mouse_hold_item = null


func MouseChange():
	mouse_position = get_global_mouse_position()
	
	if (temp_hold_item != null && drag_drop_mode == 0 && clicking && (mouse_position - click_position).length() > drag_drop_deadzone):
		drag_drop_mode = 2
		mouse_hold_item = temp_hold_item


func PlaceItem(placement_slot : Node):
	var placing_item = mouse_hold_item
	
	if placement_slot.get_child(1) != null: 
		mouse_hold_item = placement_slot.get_child(1)
		drag_drop_mode = 1
		print("test")
	
	placing_item.reparent(placement_slot) 
	print("placed")
	
