extends Control
class_name UIBoxel

@export var tile_highlighter : Control
@export var name_label : TextureRect
@export var name_text : Label
@export var boxel_image : TextureRect
@export var grayout : TextureRect
@export var boxel : Boxel

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: LevelInfo.editor_ref.HoverBoxel(self)
	if event.is_action_pressed("Primary"):
		LevelInfo.editor_ref.SelectBoxel(self) 

func _on_mouse_exited() -> void:
	LevelInfo.editor_ref.MouseExit(self)

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview : TextureRect = boxel_image.duplicate()
	preview.modulate.a = 0.5
	
	set_drag_preview(preview)
	return self

func AddBoxel(boxel_res : Boxel) -> void:
	boxel = boxel_res
	boxel_image.texture = boxel.boxel_img
	name_text.text = boxel.boxel_name

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is UIBoxel

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var prev_parent = data.get_parent()
	var prev_order = data.get_index()
	data.reparent(get_parent())
	if get_parent() is not GridContainer:
		reparent(prev_parent)
		prev_parent.move_child(self, prev_order)
