extends TextureButton

@export var file_index : int

@onready var save_container = $"../../../../.."

func _pressed():
	var load_result = SceneLoadingContainer.LoadGame(save_container.save_paths[file_index])
	if load_result is SaveData:
		print("Successfully loaded data: " + load_result.test_data)
		get_tree().change_scene_to_file("res://Scenes/Maps/Main.tscn")
	else:
		print(load_result)
		var save_status = SceneLoadingContainer.SaveGame(save_container.save_paths[file_index])
		save_container.save_slots[file_index] = (save_status == 0)
		if (save_status == 0):
			get_tree().change_scene_to_file("res://Scenes/Maps/Main.tscn")
