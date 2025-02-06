extends Window

@export var editor_overlay : CanvasLayer
@export var lvlpath_text : Label
@export var save_handler : FileDialog

func WindowReady(filepath : String):
	lvlpath_text.text = filepath

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: hide()

func _on_exit() -> void:
	notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_save() -> void:
	if lvlpath_text.text != "":
		editor_overlay.current_level_filepath = lvlpath_text.text
		editor_overlay.SaveLevel(lvlpath_text.text)
		hide()

func _on_files_selected(paths: PackedStringArray) -> void:
	printerr("Multiple Files Selected.")

func _on_file_selected(path: String) -> void:
	lvlpath_text.text = path

func _on_select_file_path() -> void:
	save_handler.popup()

func _on_dir_selected(dir: String) -> void:
	lvlpath_text.text = dir
