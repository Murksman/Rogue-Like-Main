extends Node2D

# these functions quit the game.
func _input(event):
	if event.is_action("Escape"):
		get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
