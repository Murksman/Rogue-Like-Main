extends Node
var load_file_path : String = ""
var player_data : SaveData
var player : Node2D

func StartGame(player_ref : Node2D):
	player = player_ref
	
	if ResourceLoader.exists(load_file_path):
		player_data = LoadGame(load_file_path)
		PlayerLoadData()


func SaveGame(file_path : String = load_file_path, fresh_save : bool = false):
	if !ResourceLoader.exists(load_file_path) || fresh_save:
		printerr("Creating new save...")
		return FreshSave(file_path)
	
	var player_inventory = player.backpack_inventory
	var player_ui_loadout = player.loadout_inventory
	var player_weapon_holder = player.weapon_holder
	
	var new_data = SaveData.new()
	
	new_data.player_inventory_items.resize(player_inventory.inv_size.x * player_inventory.inv_size.y)
	new_data.player_ui_weapons.resize(player_ui_loadout.inv_size.x * player_ui_loadout.inv_size.y)
	new_data.player_loadout_weapons.resize(new_data.player_ui_weapons.size())
	
	for i in new_data.player_inventory_items.size():
		var packed_item = PackedScene.new()
		var slot = player_inventory.get_child(i)
		if slot.get_children().size() > 1:
			var item = slot.get_child(1)
			AssignNodeOwners(item)
			
			packed_item.pack(item)
			new_data.player_inventory_items[i] = packed_item
	
	for i in new_data.player_ui_weapons.size():
		var inv_weapon = PackedScene.new()
		var weapon = PackedScene.new()
		var loadout_slot = player_ui_loadout.get_child(i)
		if player_weapon_holder.slotArray[i].get_children().size() > 0:
			var weapon_item = loadout_slot.get_child(1)
			var weapon_obj = player_weapon_holder.slotArray[i].get_child(0)
			
			AssignNodeOwners(weapon_item)
			AssignNodeOwners(weapon_obj)
			
			inv_weapon.pack(weapon_item)
			new_data.player_ui_weapons[i] = inv_weapon
			weapon.pack(player_weapon_holder.slotArray[i].get_child(0))
			new_data.player_loadout_weapons[i] = weapon
	
	player_data = new_data
	return ResourceSaver.save(player_data, load_file_path)


func PlayerLoadData():
	player.loadout_inventory.WipeInventory()
	player.backpack_inventory.WipeInventory()
	player.weapon_holder.WipeWeapons()
	
	var inv_items = player_data.player_inventory_items
	var weapon_objs = player_data.player_loadout_weapons
	var weapon_items = player_data.player_ui_weapons
	
	for i in inv_items.size():
		var item : PackedScene = inv_items[i]
		if inv_items[i] != null && item.can_instantiate():
			var compiled_item = item.instantiate()
			
			AssignNodeOwners(compiled_item)
			
			player.backpack_inventory.get_child(i).add_child(compiled_item)
			compiled_item.item_owner = compiled_item.get_parent()
			
			if compiled_item is WeaponItem:
				compiled_item.weapon_object = compiled_item.get_child(0)
				compiled_item.weapon_object.projectileContainer = player.projectileContainer
	
	for i in weapon_objs.size():
		var weapon : PackedScene = weapon_objs[i]
		var weapon_item : PackedScene = weapon_items[i]
		if weapon != null && weapon.can_instantiate() && weapon_item != null && weapon_item.can_instantiate():
			var compiled_weapon = weapon.instantiate()
			player.weapon_holder.slotArray[i].add_child(compiled_weapon)
			compiled_weapon.projectileContainer = player.projectileContainer
			player.weapon_holder.AddWeapon(true, i)
			
			var compiled_weapon_item = weapon_item.instantiate()
			player.loadout_inventory.get_child(i).add_child(compiled_weapon_item)
			compiled_weapon_item.item_owner = compiled_weapon_item.get_parent()
			compiled_weapon_item.weapon_object = compiled_weapon
			
			AssignNodeOwners(compiled_weapon)
			AssignNodeOwners(compiled_weapon_item)


func LoadGame(file_path : String):
	if !ResourceLoader.exists(file_path):
		return "File Not Found."
	
	player_data = ResourceLoader.load(file_path)
	load_file_path = file_path
	return player_data


func FreshSave(file_path : String):
	load_file_path = file_path
	
	player_data = SaveData.new()
	
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
			printerr("Saved. Loading Menu...")
			get_tree().change_scene_to_file("res://Scenes/Maps/Menu.tscn")
		else: printerr("Error Exiting the level. [" + load_file_path + "] - " + str(save_status))
	else:
		printerr("Error Exiting the level. [" + load_file_path + "] - error code: " + str(save_status))


func AssignNodeOwners(parent_node):
	for node in NodeTreeFetch(parent_node):
		node.owner = parent_node


func NodeTreeFetch(node : Node, node_processing_list : Array[Node] = []):
	for child in node.get_children():
		node_processing_list.append(child)
		NodeTreeFetch(child, node_processing_list)
	return node_processing_list



