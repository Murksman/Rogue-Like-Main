extends Control

@export var editor_main : CanvasLayer
@export var pencil_tool : Control
@export var shape_tool : Control
@export var hollow_shape_tool : Control
@export var tool_selection_group : ButtonGroup
@export var blend_curve : Curve
@export var blend_size : float
@export var blend_speed : float

var selected_tool : int = -1
var boxel_type : Boxel
var tool_group : Container

func ToolPressed() -> void:
	if !tool_selection_group.get_pressed_button(): 
		selected_tool = -1
		return
	selected_tool = tool_selection_group.get_pressed_button().tool_index

func SelectedBoxel(boxel : Boxel):
	for child in get_children():
		child.visible = true
	
	if boxel is LightBoxel:
		visible = false
	else:
		visible = true

func _process(delta: float) -> void:
	if !editor_main.editing: return
	
	if tool_group:
		for child in tool_group.get_children():
			if selected_tool == child.tool_index:
				child.pressed_blend_state += delta * blend_speed
			else:
				child.pressed_blend_state -= delta * blend_speed
			
			child.pressed_blend_state = clamp(child.pressed_blend_state, 0.0, 1.0)
			var sampled = blend_curve.sample(child.pressed_blend_state)
			child.custom_minimum_size.x = 64 + 24 * sampled
			child.material.set_shader_parameter("selected_blend", sampled)

func SelectEraser() -> void:
	pass
