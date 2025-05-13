extends Control

@export var editor_main : CanvasLayer
@export var eraser : TextureButton
@export var pencil_tool : Control
@export var shape_tool : Control
@export var hollow_shape_tool : Control
@export var tool_selection_group : ButtonGroup
@export var blend_speed : float

@export var blend_buttons : Array[TextureButton]

var selected_tool : int = -1
var boxel_type : LvlObject

func ToolPressed() -> void:
	if !tool_selection_group.get_pressed_button(): 
		selected_tool = -1
		return
	
	selected_tool = tool_selection_group.get_pressed_button().tool_index

func SelectedBoxel(boxel : LvlObject):
	for child in get_children():
		child.visible = true
	
	if boxel is LightObject || boxel is EntityObject:
		visible = false
	else:
		visible = true

func _process(delta: float) -> void:
	if !editor_main.editing: return
	
	for child in blend_buttons:
		if child.button_pressed:
			child.pressed_blend_state += delta * blend_speed
		else:
			child.pressed_blend_state -= delta * blend_speed
		
		child.pressed_blend_state = clamp(child.pressed_blend_state, 0.0, 1.0)
		var sampled = smoothstep(0.0, 1.0, child.pressed_blend_state)
		
		child.custom_minimum_size.x = 64 + 10 * sampled
		child.material.set_shader_parameter("selected_blend", sampled)

func SelectEraser() -> void:
	pass
