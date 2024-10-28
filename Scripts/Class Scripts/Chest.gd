extends ActionableObject
class_name Chest

@export var inventory_size : Vector2i
@export var inventory_items : Array[InventoryItem]

@export_group("Loot Settings")
@export var loot_table : LootTable
@export var quantity_multiplier : int
@export var rarity_multiplier : int

@onready var item_container : Control = $"Item Container"

func _ready():
	GenerateItems()
	RecalculateContent()


func GenerateItems(generate_fresh : bool = true, quantity : int = quantity_multiplier):
	var space_counter = 0
	
	var items = loot_table.RollItems(rarity_multiplier, quantity_multiplier)
	
	for item in items:
		if !(item is PackedScene): 
			space_counter += 1
			continue
		
		var new_item = item.instantiate()
		new_item.inv_position = space_counter
		new_item.item_owner = item_container
		
		item_container.add_child(new_item)
		
		space_counter += 1

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

func RecalculateContent():
	inventory_items.resize(inventory_size.x * inventory_size.y)
	var slot = 0
	
	for child in item_container.get_children():
		if not child is InventoryItem:
			inventory_items[slot] = null
			continue
		inventory_items[slot] = child
		slot += 1
	
	for item in inventory_items:
		if !item: continue
		item.item_owner = item.get_parent()
