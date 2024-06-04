extends Camera2D

var time : float = 0.0
@export var mousePosCamMultiplier : float
@export var cam_smooth : float

@onready var cone_shader : ColorRect = $"Shader Container/Vision Cone Effects/Vision Cone Color Control"
@onready var vis_mask_cam : Camera2D = $"../../Visibility Light Mask/Mask Cam"

func _process(delta):
	offset = (get_viewport().get_mouse_position() - Vector2(960, 540)) * mousePosCamMultiplier
	
	var direction = offset.normalized()
	$Orientation.look_at($Orientation.global_position + direction)
	
	cone_shader.material.set_shader_parameter("look_direction", direction)
	cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))

	global_position = lerp(global_position, $"..".global_position, cam_smooth * delta)
	vis_mask_cam.global_position = global_position
	vis_mask_cam.offset = offset
	$"Shader Container/Debug_Visibility_Layer".position = offset
