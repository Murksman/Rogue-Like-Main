extends ActionableObject
class_name Chest

@export var inventory_size : Vector2i

@export var inventory_items : Array[InventoryItem]

@onready var item_container : Control = $"Item Container"

func _ready():
	inventory_items.resize(inventory_size.x * inventory_size.y)
	var temp_iterable = 0
	for child in item_container.get_children():
		if not child is InventoryItem: continue
		inventory_items[temp_iterable] = child
		temp_iterable += 1
	
	
	for item in inventory_items:
		if !item: continue
		item.item_owner = item.get_parent()


func AddItem(item : InventoryItem, inv_position : int):
	inventory_items[inv_position] = item
	item.item_owner = self
	item.reparent(item_container)

func _on_child_entered_tree(node):
	if not node is InventoryItem: return
	if node.item_owner.get_parent() == self: return
	
	for i in inventory_items.size():
		if inventory_items[i] == null:
			inventory_items[i] = node
			node.item_owner = node.get_parent()
