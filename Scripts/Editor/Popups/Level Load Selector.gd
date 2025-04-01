extends Window

@export var lvl_list : Control
@export var lvlpath_text : Label
@export var open_level_handler : FileDialog
@export var editor_overlay : CanvasLayer

var selected_path : String
var select_path_button : Control

var lvl_file_control := preload("res://Prefabs/Editor/level_file.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: hide()

func WindowReady() -> void:
	selected_path = ""
	select_path_button = null
	
	for child in lvl_list.get_children():
		child.queue_free()
	
	var lvl_files := DirAccess.get_files_at(SceneLoadingContainer.levels_load_path)
	
	for file in lvl_files:
		var new_file_path = lvl_file_control.instantiate()
		new_file_path.filepath_text.text = SceneLoadingContainer.levels_load_path + "/" + file
		lvl_list.add_child(new_file_path)

func SelectListLevel(path : String, path_button : Control) -> void:
	if path_button == select_path_button: return
	
	selected_path = path
	lvlpath_text.text = selected_path
	select_path_button = path_button
	for child in lvl_list.get_children():
		child.selector_bar.visible = child == select_path_button

func Unselect():
	lvlpath_text.text = ""
	selected_path = ""
	
	if select_path_button: 
		select_path_button.selector_bar.visible = false
		select_path_button = null

func _on_load_level() -> void:
	if lvlpath_text.text != "":
		editor_overlay.LoadLevel(selected_path)
		hide()

func _on_close_requested() -> void:
	visible = false

func _on_import_external() -> void:
	open_level_handler.popup()

func _on_receive_level_path(file_path : String) -> void:
	selected_path = file_path
	lvlpath_text.text = selected_path


func _on_exit() -> void:
	notification(NOTIFICATION_WM_CLOSE_REQUEST)
