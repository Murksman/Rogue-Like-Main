extends Control
class_name UIBoxel

@export var tile_highlighter : Control
@export var name_text : Label
@export var boxel_image : TextureRect
@export var grayout : TextureRect
@export var boxel : LvlObject
@export var boxel_res_path : String

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: LevelInfo.editor_ref.HoverBoxel(self)
	if event.is_action_pressed("Primary"):
		if event is InputEventMouseButton && event.double_click:
			LevelInfo.editor_ref.EditBoxel(boxel)
		else:
			LevelInfo.editor_ref.SelectBoxel(self) 

func _on_mouse_exited() -> void:
	LevelInfo.editor_ref.MouseExit(self)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview_parent = Control.new()
	var preview = TextureRect.new()
	preview.texture = boxel_image.texture
	preview.position = Vector2(-16,-16)
	preview_parent.add_child(preview)
	preview.owner = preview_parent
	preview.modulate.a = 0.5
	
	set_drag_preview(preview_parent)
	return self

func Delete() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(boxel_res_path))
	queue_free()

func AddBoxel(boxel_res : LvlObject, file_path : String) -> void:
	boxel_res_path = file_path
	
	boxel = boxel_res
	boxel_image.texture = boxel.img
	name_text.text = boxel.name

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is UIBoxel

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var prev_parent = data.get_parent()
	var prev_order = data.get_index()
	var curr_parent = get_parent()
	
	data.reparent(curr_parent, false)
	if curr_parent is GridContainer: curr_parent.move_child(data, get_index())
	else: data.position = (curr_parent.size - data.size) / 2
	
	reparent(prev_parent, false)
	if prev_parent is GridContainer: prev_parent.move_child(self, prev_order)
	else: position = (prev_parent.size - self.size) / 2
