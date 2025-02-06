extends Control

@export var editor_main : CanvasLayer
@export var connector_boxel_tools : Control
@export var scatter_boxel_tools : Control
@export var unit_boxel_tools : Control
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
	

func _process(delta: float) -> void:
	if editor_main.selected_boxel: 
		if !boxel_type || editor_main.selected_boxel.boxel.get_script() != boxel_type.get_script():
			print("test")
			boxel_type = editor_main.selected_boxel.boxel
			
			for child in get_children():
				child.visible = false
			
			if boxel_type is UnitBoxel:
				unit_boxel_tools.visible = true
				tool_group = unit_boxel_tools
			elif boxel_type is ConnectorBoxel:
				connector_boxel_tools.visible = true
				tool_group = connector_boxel_tools
			elif boxel_type is ScatterBoxel:
				scatter_boxel_tools.visible = true
				tool_group = scatter_boxel_tools
		else: boxel_type = editor_main.selected_boxel.boxel
		
		
	else: boxel_type = null
	
	
	if !boxel_type:
		for child in get_children():
			child.visible = false

	
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
