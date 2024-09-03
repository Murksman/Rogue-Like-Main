extends TextureButton

@export var file_index : int

@onready var save_container = $"../../../../.."

func _pressed():
	var delete_err = SceneLoadingContainer.DeleteSave(save_container.save_paths[file_index])
	if delete_err != "File Removed.":
		print(delete_err)
	else:
		print("Deleted File")
		save_container.UpdateFileStatus()
