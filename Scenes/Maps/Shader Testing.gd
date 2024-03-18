extends Camera2D

var time : float = 0.0
var primeShader : ColorRect
var secondaryShader : ColorRect

func _ready():
	primeShader = $CanvasLayer/BackBufferCopy2/Primary
	secondaryShader = $CanvasLayer/BackBufferCopy/Secondary

func _process(delta):
	pass
	#time += delta * 10
	#var radius = sin(time)
	#var radius2 = sin(time - 1)
	#primeShader.material.set_shader_parameter("r_displacement", Vector2(2.0 + radius * 3, 0))
	#primeShader.material.set_shader_parameter("g_displacement", Vector2(0.0, -1.0 + radius * 2))
	#primeShader.material.set_shader_parameter("b_displacement", Vector2(1.0 - radius * 4, 0.0))


func shader_orientation(direction):
	secondaryShader.material.set_shader_parameter("look_direction", direction)

