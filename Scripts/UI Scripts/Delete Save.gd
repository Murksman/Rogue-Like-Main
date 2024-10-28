extends TextureButton

@export var file_index : int

@onready var save_container = $"../../../../.."

func _pressed():
	var delete_err = SceneLoadingContainer.DeleteSave(save_container.save_paths[file_index])
	if delete_err != "File Removed.":
		printerr(delete_err, " Delete Error")
	else:
		printerr("Deleted File")
		save_container.UpdateFileStatus()
