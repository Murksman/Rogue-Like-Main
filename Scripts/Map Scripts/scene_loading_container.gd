extends Node
var load_file_path : String = ""
var player_data : SaveData

@onready var player = get_node("/root/World/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")
	if ResourceLoader.exists(load_file_path):
		print("File Save Found at: \"" + load_file_path + "\"")
		player_data = ResourceLoader.load(load_file_path)
		print(player_data)
	#else:
		#player_data = SaveData.new()
		#print(player, " ", player_data)

func SaveGame(file_path : String = load_file_path):
	if !ResourceLoader.exists(load_file_path):
		print("Creating new save...")
		return FreshSave(file_path)
	
	var player_inventory = player.backpack_inventory
	player_data.player_inventory_items.resize(player_inventory.inv_size.x * player_inventory.inv_size.y)
	
	for i in player_data.player_inventory_items.size():
		var item = PackedScene.new()
		item.pack(player_inventory.get_child(i).get_child(1))
		player_data.player_inventory_items[i] = item
	
	return ResourceSaver.save(player_data, load_file_path)

func LoadGame(file_path : String):
	if !ResourceLoader.exists(file_path):
		return "File Not Found."
	
	player_data = ResourceLoader.load(file_path)
	return player_data

func FreshSave(file_path : String):
	load_file_path = file_path
	
	player_data = SaveData.new()
	print(ResourceSaver.save(player_data, load_file_path))
	return ResourceSaver.save(player_data, load_file_path)
	
