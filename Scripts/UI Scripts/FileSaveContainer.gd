extends VBoxContainer

@export var save_paths : Array[String]
@export var save_slots : Array[bool]

var packed_scene : PackedScene

func LoadFile(file_index : int):
	if save_slots[file_index] && ResourceLoader.exists("user://" + save_paths[file_index] + ".tscn"):
		return ResourceLoader.load("user://" + save_paths[file_index] + ".tscn")

func SaveFile(file_index : int, data : Resource = null):
	#if !ResourceLoader.exists("user://" + save_paths[file_index] + ".tscn"):
		#FileAccess.open("user://" + save_paths[file_index] + ".tscn", FileAccess.WRITE)
	
	packed_scene = PackedScene.new()
	packed_scene.pack(get_tree().get_current_scene())
	print(ResourceSaver.save(packed_scene , "user://" + save_paths[file_index] + ".tscn"))
