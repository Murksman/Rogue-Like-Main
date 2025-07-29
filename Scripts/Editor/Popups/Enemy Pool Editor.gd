extends Window

var curr_pool : EnemyPool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: hide()

func _on_exit_button_pressed() -> void:
	notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_delete_pool_pressed() -> void:
	pass # Replace with function body.

func Open(pool : EnemyPool):
	visible = true
	popup()
	
	curr_pool = pool
	
	
