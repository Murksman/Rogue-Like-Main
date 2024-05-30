extends Camera2D

var time : float = 0.0
@export var mousePosCamMultiplier : float
@onready var cone_shader : ColorRect = $"../Shader Container/Vision Cone Effects/Vision Cone Color Control"

func shader_orientation(direction):
	offset = (get_viewport().get_mouse_position() - Vector2(960, 540)) * mousePosCamMultiplier
	cone_shader.material.set_shader_parameter("look_direction", direction)
	cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))
	#$CanvasLayer.mouseShaderOffset = Vector2(offset.x / 540.0, offset.y / 540.0)
