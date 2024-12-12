extends FileDialog

var file_open_return : Object = null

func _on_file_selected(path: String) -> void:
	if file_open_return.has_method("FileImportCatch"):
		var paths : Array[String] = [path]
		file_open_return.FileImportCatch(paths)

func _on_files_selected(paths: PackedStringArray) -> void:
	if file_open_return.has_method("FileImportCatch"):
		file_open_return.FileImportCatch(paths)
