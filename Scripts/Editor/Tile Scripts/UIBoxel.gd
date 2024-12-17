extends Control
class_name UIBoxel

@export var tile_highlighter : Control
@export var name_label : TextureRect
@export var name_text : Label
@export var boxel_image : TextureRect
@export var boxel : Boxel

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: $"..".HoverTile(self)
	if event.is_action_pressed("Primary"):
		$"..".SelectTile(self)

func _on_mouse_exited() -> void:
	$"..".MouseExit(self)

func AddBoxel(boxel_res : Boxel) -> void:
	boxel = boxel_res
	boxel_image.texture = boxel.boxel_img
	name_text.text = boxel.boxel_name
