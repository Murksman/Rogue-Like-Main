extends Camera2D

var time : float = 0.0
@onready var primeShader : ColorRect = $CanvasLayer/BackBufferCopy2/Primary
@onready var secondaryShader : ColorRect = $CanvasLayer/BackBufferCopy/Secondary
@onready var shadowCam : Camera2D = $"../../../../Vision Plane Controller/Vision Plane/Camera2D"

@export var visionPlane : SubViewport
@export var mousePosCamMultiplier : float


func shader_orientation(direction):
	offset = (Vector2(DisplayServer.mouse_get_position()) - Vector2(960, 540)) * mousePosCamMultiplier
	shadowCam.offset = offset
	
	var mouseShaderOffset = Vector2(offset.x / 540.0, offset.y / 540.0)
	secondaryShader.material.set_shader_parameter("look_direction", direction)
	secondaryShader.material.set_shader_parameter("mouse_offset", mouseShaderOffset)
