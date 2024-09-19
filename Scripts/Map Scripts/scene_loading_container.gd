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
	var player_ui_loadout = player.loadout_inventory
	var player_weapon_holder = player.weapon_holder
	
	#print(player.weapon_holder.get_children()[0].get_children()[0].get_children())
	
	player_data.player_inventory_items.resize(player_inventory.inv_size.x * player_inventory.inv_size.y)
	player_data.player_ui_weapons.resize(player_ui_loadout.inv_size.x * player_ui_loadout.inv_size.y)
	player_data.player_loadout_weapons.resize(player_data.player_ui_weapons.size())
	
	
	for i in player_data.player_inventory_items.size():
		var packed_item = PackedScene.new()
		var slot_children = player_inventory.get_child(i).get_children()
		if slot_children.size() > 1: 
			packed_item.pack(player_inventory.get_child(i).get_child(1))
			player_data.player_inventory_items[i] = packed_item
	
	for i in player_data.player_ui_weapons.size():
		var inv_weapon = PackedScene.new()
		var weapon = PackedScene.new()
		if player_weapon_holder.get_child(i).get_children().size() > 1:
			inv_weapon.pack(player_ui_loadout.get_child(i).get_child(1))
			player_data.player_ui_weapons[i] = inv_weapon
			weapon.pack(player_weapon_holder.slotArray[i].get_child(0))
			player_data.player_loadout_weapons[i] = weapon
	
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
	#print(ResourceSaver.save(player_data, load_file_path))
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
		print(save_status)


func PlayerLoadData():
	player.loadout_inventory.WipeInventory()
	player.backpack_inventory.WipeInventory()
	player.weapon_holder.WipeWeapons()
	
	var inv_items = player_data.player_inventory_items
	for i in inv_items.size():
		var item : PackedScene = inv_items[i]
		if inv_items[i] != null && item.can_instantiate():
			var compiled_item = item.instantiate()
			print(compiled_item.get_children(), " - Compiled Item Children")
			if compiled_item is WeaponItem:
				compiled_item.weapon_object = compiled_item.get_child(0)
			player.backpack_inventory.get_child(i).add_child(compiled_item)
	
	var weapon_objs = player_data.player_loadout_weapons
	var weapon_items = player_data.player_ui_weapons
	for i in weapon_objs.size():
		var weapon : PackedScene = weapon_objs[i]
		var weapon_item : PackedScene = weapon_items[i]
		if weapon != null && weapon.can_instantiate() && weapon_item != null && weapon_item.can_instantiate():
			var compiled_weapon = weapon.instantiate()
			player.weapon_holder.slotArray[i].add_child(compiled_weapon)
			var compiled_weapon_item = weapon_item.instantiate()
			player.loadout_inventory.get_child(i).add_child(compiled_weapon_item)
			compiled_weapon_item.weapon_object = compiled_weapon

