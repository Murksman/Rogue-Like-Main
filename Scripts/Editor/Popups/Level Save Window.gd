extends Window

@export var editor_overlay : CanvasLayer
@export var lvlpath_text : Label

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: hide()

func _on_exit() -> void:
	notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_save() -> void:
	if DirAccess.get_open_error(): editor_overlay.SaveLevel(lvlpath_text.text)
