extends Camera2D

var time : float = 0.0
@export var mousePosCamMultiplier : float

var direction

func shader_orientation(dir):
	offset = (get_viewport().get_mouse_position() - Vector2(960, 540)) * mousePosCamMultiplier
	#$CanvasLayer.mouseShaderOffset = Vector2(offset.x / 540.0, offset.y / 540.0)
	direction = dir
