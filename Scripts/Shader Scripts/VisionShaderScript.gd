extends CanvasLayer

@onready var primeShader : ColorRect = $BackBufferCopy2/Primary
@onready var secondaryShader : ColorRect = $BackBufferCopy/Secondary
var mouseShaderOffset : Vector2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	secondaryShader.material.set_shader_parameter("look_direction", get_parent().direction)
	secondaryShader.material.set_shader_parameter("mouse_offset", mouseShaderOffset)
