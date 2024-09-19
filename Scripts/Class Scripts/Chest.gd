extends ActionableObject
class_name Chest

@export var inventory_size : Vector2i

@export var inventory_items : Array[InventoryItem]

@onready var item_container : Control = $"Item Container"

func _ready():
	RecalculateContent()


func AddItem(item : InventoryItem, inv_position : int):
	print("AddItem")
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

func RecalculateContent():
	inventory_items.resize(inventory_size.x * inventory_size.y)
	var slot = 0
	print("Recalc Chest Inv. - ", item_container.get_children())
	print(inventory_items)
	for child in item_container.get_children():
		if not child is InventoryItem: 
			inventory_items[slot] = null
			continue
		#print("e")
		inventory_items[slot] = child
		slot += 1
	
	for item in inventory_items:
		if !item: continue
		item.item_owner = item.get_parent()
