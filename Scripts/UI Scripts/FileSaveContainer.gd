extends VBoxContainer

@export var save_paths : Array[String]
@export var save_slots : Array[bool]

var save_data : SaveData

func LoadFile(file_index : int):
	if save_slots[file_index] && ResourceLoader.exists("user://" + save_paths[file_index] + ".tscn"):
		return ResourceLoader.load("user://" + save_paths[file_index] + ".tscn")

func SaveFile(file_index : int, data : Resource = null):
	#if !ResourceLoader.exists("user://" + save_paths[file_index] + ".tscn"):
		#FileAccess.open("user://" + save_paths[file_index] + ".tscn", FileAccess.WRITE)
	
	save_data = SaveData.new()
	save_data.test_data = $"../TextEdit".text
	print(save_data , "user://" + save_paths[file_index] + ".tscn"))
	
	print(ResourceSaver.save(save_data , "user://" + save_paths[file_index] + ".tscn"))
