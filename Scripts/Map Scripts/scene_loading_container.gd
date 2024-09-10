extends Node
var load_file_path : String = ""
var player_data : SaveData
var player : Node2D

func StartGame(player_ref : Node2D):
	player = player_ref
	
	if ResourceLoader.exists(load_file_path):
		print("File Save Found at: \"" + load_file_path + "\"")
		player_data = LoadGame(load_file_path)
		PlayerLoadData()
		print(player_data)


func SaveGame(file_path : String = load_file_path):
	if !ResourceLoader.exists(load_file_path):
		print("Creating new save...")
		return FreshSave(file_path)
	
	print(load_file_path + "\n" + str(player))
	var player_inventory = player.backpack_inventory
	player_data.player_inventory_items.resize(player_inventory.inv_size.x * player_inventory.inv_size.y)
	player_data.player_inventory_items.fill(null)
	
	for i in player_data.player_inventory_items.size():
		var item = PackedScene.new()
		var slot_children = player_inventory.get_child(i).get_children()
		if slot_children.size() > 1: 
			item.pack(player_inventory.get_child(i).get_child(1))
			player_data.player_inventory_items[i] = item
	
	return ResourceSaver.save(player_data, load_file_path)


func LoadGame(file_path : String):
	if !ResourceLoader.exists(file_path):
		return "File Not Found."
	
	player_data = ResourceLoader.load(file_path)
	load_file_path = file_path
	return player_data


func FreshSave(file_path : String):
	load_file_path = file_path
	
	player_data = SaveData.new()
	print(ResourceSaver.save(player_data, load_file_path))
	return ResourceSaver.save(player_data, load_file_path)


func DeleteSave(file_path : String):
	if ResourceLoader.exists(file_path):
		var delete_err = DirAccess.remove_absolute(file_path)
		if delete_err != OK: return "Error: cannot delete file. Lack of permissions or invalid file path."
		return "File Removed."
	else:
		return "Error: cannot delete file, No file found."


func ExitLevel():
	var save_status = SaveGame()
	if save_status is int:
		if save_status == 0:
			print("Saved. Loading Menu...")
			get_tree().change_scene_to_file("res://Scenes/Maps/Menu.tscn")
		else: print("Error Exiting the level. [" + load_file_path + "] - " + str(save_status))
	else:
		print("Error Exiting the level. [" + load_file_path + "]")


func PlayerLoadData():
	player.backpack_inventory.WipeInventory()
	
	var inv_items = player_data.player_inventory_items
	for i in inv_items.size():
		var item : PackedScene = inv_items[i]
		if inv_items[i] != null && item.can_instantiate():
			var compiled_item = item.instantiate()
			print(compiled_item.get_class())
			player.backpack_inventory.get_child(i).add_child(compiled_item)

