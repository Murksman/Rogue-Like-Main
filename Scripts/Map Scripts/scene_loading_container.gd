extends Node
var load_file_path : String = "user://save1.tres"
var player_data : SaveData

@onready var player = get_node("/root/World/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")
	if ResourceLoader.exists(load_file_path):
		player_data = ResourceLoader.load(load_file_path)
		print(player_data)
	else:
		player_data = SaveData.new()
		print(player, " ", player_data)

func SaveGame():
	print("test")
	var player_inventory = player.backpack_inventory
	player_data.player_inventory_items.resize(player_inventory.inv_size.x * player_inventory.inv_size.y)
	for i in player_data.player_inventory_items.size():
		var item = PackedScene.new()
		item.pack(player_inventory.get_child(i).get_child(1))
		player_data.player_inventory_items[i] = item
	
	ResourceSaver.save(player_data, load_file_path)
