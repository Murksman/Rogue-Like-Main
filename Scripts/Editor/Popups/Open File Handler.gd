extends FileDialog

var file_open_return : Object = null
var normal_import : bool = false

func _on_file_selected(path: String) -> void:
	if file_open_return.has_method("FileImportCatch"):
		var paths : Array[String] = [path]
		file_open_return.ImageImportCatch(paths)

func _on_files_selected(paths: PackedStringArray) -> void:
	if file_open_return.has_method("FileImportCatch"):
		file_open_return.ImageImportCatch(paths)

func RequestOpen(open_return : Object, is_normal_import : bool = false):
	normal_import = is_normal_import
	file_open_return = open_return
	popup()
