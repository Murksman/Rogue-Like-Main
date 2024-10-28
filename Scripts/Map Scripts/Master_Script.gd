extends Node

func _ready():
	SceneLoadingContainer.StartGame($Player)

func _input(event):
	if event.is_action("Escape"):
		get_tree().quit()

func _notification(note_event):
	if note_event == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()


