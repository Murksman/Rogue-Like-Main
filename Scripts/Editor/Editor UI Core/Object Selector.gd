extends Control

@export var editor_layer : CanvasLayer
@export var rotation_axis : Line2D

var mouse_engaged = false
var anchor_point = Vector2.ZERO
var rotation_mode = false

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Editor Primary"):
		var mouse_dist = (event.global_position - global_position - Vector2(32.0, 32.0)).length()
		if mouse_dist > 40.0: return
		
		rotation_mode = mouse_dist > 20.0
		mouse_engaged = true
	
	if mouse_engaged && event is InputEventMouseMotion:
		anchor_point = (event.global_position - global_position - Vector2(32.0, 32.0)) / 2
		
		if !rotation_mode:
			global_position += anchor_point
			editor_layer.selected_world_obj.global_position += anchor_point
			anchor_point = Vector2.ZERO

func _process(delta: float) -> void:
	if !mouse_engaged: return
	
	if !Input.is_action_pressed("Editor Primary"):
		mouse_engaged = false
		return
	
	if Input.is_action_just_released("Editor Primary"): 
		mouse_engaged = false
		return
	
	if rotation_mode:
		rotation_axis.rotation = anchor_point.angle()
		editor_layer.selected_world_obj.rotation = rotation_axis.rotation
