extends VBoxContainer

@export var save_paths : Array[String]
@export var save_slots : Array[bool]

@export var save_data : SaveData = null

func LoadFile(file_index : int):
	if save_slots[file_index] && ResourceLoader.exists("user://" + save_paths[file_index] + ".tres"):
		return ResourceLoader.load("user://" + save_paths[file_index] + ".tres")
	else:
		return "File not found."



func SaveFile(data : Resource = null, save_index : int = 0):
	#if !ResourceLoader.exists("user://" + save_paths[file_index] + ".tscn"):
		#FileAccess.open("user://" + save_paths[file_index] + ".tscn", FileAccess.WRITE)
	
	save_data = SaveData.new()
	save_data.test_data = $"../TextEdit".text
	print(save_data.test_data)
	
	print(ResourceSaver.save(save_data , "user://" + save_paths[save_index] + ".tres"))
