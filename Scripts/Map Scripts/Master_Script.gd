extends Node2D

@export var projectile_container : Node2D
@export var enemy_container : Node2D
@export var player : Node2D
@export var editor_layer : CanvasLayer
@export var vision_occluder_container : Node2D

func _ready():
	SceneLoadingContainer.StartGame(self)
	LevelInfo.projectile_container = projectile_container

func _process(delta: float) -> void:
	player.camera.pseudoProcess(delta)
	editor_layer.pseudoProcess(delta)

func _input(event: InputEvent) -> void:
	pass
	#if event.is_action("Escape"): 
		#notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(note_event):
	if note_event == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
