extends Camera2D

var time : float = 0.0
@export var mousePosCamMultiplier : float
@export var cam_smooth : float

@onready var cone_shader : ColorRect = $"Shader Container/Vision Cone Effects/Vision Cone Color Control"
@onready var vis_mask_cone_shader : ColorRect = $"../../Visibility Light Mask/Light Mask Shader"
@onready var vis_mask_cam : Camera2D = $"../../Visibility Light Mask/Mask Cam"
@onready var entity_rendering_cam : Camera2D = $"../../Entity Rendering Layer/Mask Cam"
@onready var mouse_light : Light2D = $Orientation/Flashlight
@onready var Orientation : Node2D = $Orientation



func _process(delta):
	var mouse_offset = (get_viewport().get_mouse_position() - Vector2(960, 540))
	offset = mouse_offset * mousePosCamMultiplier
	
	var direction = offset.normalized()
	Orientation.look_at(Orientation.global_position + direction)
	
	cone_shader.material.set_shader_parameter("look_direction", direction)
	cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))
	vis_mask_cone_shader.material.set_shader_parameter("look_direction", direction)
	vis_mask_cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))
	
	global_position = lerp(global_position, $"..".global_position, cam_smooth * delta)
	var lightLength = ((mouse_offset * mousePosCamMultiplier) + (mouse_offset / zoom)).length()
	mouse_light.scale.x = 1 + (lightLength / 100)
	mouse_light.scale.y = 1 + (lightLength / 200)
	mouse_light.offset.x = lightLength / mouse_light.scale.x
	
	vis_mask_cam.global_position = global_position
	vis_mask_cam.offset = offset
	entity_rendering_cam.global_position = global_position
	entity_rendering_cam.offset = offset
	$"Shader Container/Debug_Visibility_Layer".position = offset
	$"Shader Container/Masked_Entity_Layer".position = offset
