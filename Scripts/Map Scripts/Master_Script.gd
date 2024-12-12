extends Node

@onready var projectile_container : Node2D = $"Projectile Container"

func _ready():
	SceneLoadingContainer.StartGame($Player)
	LevelInfo.projectile_container = projectile_container

func _input(event):
	if event.is_action("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(note_event):
	if note_event == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
