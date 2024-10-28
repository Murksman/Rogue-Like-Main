extends TextureButton

@export var file_index : int

@onready var save_container = $"../../../../.."

func _pressed():
	var load_path = save_container.save_paths[file_index]
	var load_result = SceneLoadingContainer.LoadGame(load_path)
	
	if load_result is SaveData:
		print("Loading Save Under (" + str(load_path) + ")")
		SceneLoadingContainer.load_file_path = load_path
		get_tree().change_scene_to_file("res://Scenes/Maps/Main.tscn")
	else:
		var save_status = SceneLoadingContainer.SaveGame(load_path, true)
		save_container.save_slots[file_index] = (save_status == 0)
		if (save_status == 0):
			get_tree().change_scene_to_file("res://Scenes/Maps/Main.tscn")
