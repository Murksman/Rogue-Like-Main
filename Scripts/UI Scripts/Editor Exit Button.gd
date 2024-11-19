extends Button

@onready var edit_layer : CanvasLayer = $"../../../../.."


func _pressed() -> void:
	edit_layer.visible = false
	edit_layer.player.editor_open = false
