extends Camera2D

var time : float = 0.0
@onready var primeShader : ColorRect = $CanvasLayer/BackBufferCopy2/Primary
@onready var secondaryShader : ColorRect = $CanvasLayer/BackBufferCopy/Secondary

@export var visionPlane : SubViewport

# @onready var player : CharacterBody2D = $"../.."

#func _process(delta):
#	var visionShape = visionPlane.get_texture()
#	secondaryShader.material.set_shader_parameter("vision_shape", visionShape)

func shader_orientation(direction):
	secondaryShader.material.set_shader_parameter("look_direction", direction)

