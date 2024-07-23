extends Camera2D

var time : float = 0.0
@export var mousePosCamMultiplier : float
@export var cam_smooth : float
@export var ui_effect_smooth : float
@export var inventorySpacing : float

@onready var cone_shader : ColorRect = $"Shader Layer/Shader Container/Vision Cone Effects/Vision Cone Color Control"
@onready var vis_mask_cone_shader : ColorRect = $"../../Visibility Light Mask/Light Mask Shader"
@onready var screen_effects_shader : ColorRect = $"Shader Layer/Shader Container/Screen Effect Controls/Screen Controls"
@onready var vis_mask_cam : Camera2D = $"../../Visibility Light Mask/Mask Cam"
@onready var entity_rendering_cam : Camera2D = $"../../Entity Rendering Layer/Mask Cam"
@onready var flash_light : Light2D = $Orientation/Flashlight
@onready var wall_flash_light : Light2D = $"Orientation/Flashlight (Wall)"
@onready var Orientation : Node2D = $Orientation
@onready var player : CharacterBody2D = $".."

var global_mouse_pos : Vector2

var ui_screen_effects : float = 0.0

func _physics_process(delta):
	ui_screen_effects = lerpf(ui_screen_effects, (1.0 if player.ui_open else 0.0), ui_effect_smooth * delta)

func _process(delta):
	global_mouse_pos = get_viewport().get_mouse_position()
	#var mouse_offset = (global_mouse_pos - Vector2(960, 540)) + Vector2((inventorySpacing if player.ui_open else 0.0), 0.0) * 2
	var mouse_offset = global_mouse_pos - Vector2(960, 540)
	offset = (mouse_offset * mousePosCamMultiplier) + Vector2((inventorySpacing if player.ui_open else 0.0), 0.0)
	
	var direction = (offset - (Vector2((inventorySpacing if player.ui_open else 0.0), 0.0))).normalized()
	
	
	cone_shader.material.set_shader_parameter("look_direction", direction)
	cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))
	vis_mask_cone_shader.material.set_shader_parameter("look_direction", direction)
	vis_mask_cone_shader.material.set_shader_parameter("player_offset", Vector2(offset.x / 960, offset.y / 540))
	screen_effects_shader.material.set_shader_parameter("ui_effects", ui_screen_effects)
	
	if !player.ui_open:
		Orientation.look_at(Orientation.global_position + direction)
		
		var lightLength = ((mouse_offset * mousePosCamMultiplier) + (mouse_offset / zoom)).length()
		flash_light.scale.x = 0.2 + (lightLength / 100)
		flash_light.energy = 5.0 / sqrt(flash_light.scale.x)
		flash_light.scale.y = 0.2 + (lightLength / 200)
		flash_light.offset.x = lightLength / flash_light.scale.x
		wall_flash_light.scale = flash_light.scale
		wall_flash_light.offset = flash_light.offset
		wall_flash_light.energy = flash_light.energy
	
	vis_mask_cam.global_position = global_position
	vis_mask_cam.offset = offset
	entity_rendering_cam.global_position = global_position
	entity_rendering_cam.offset = offset
	$Debug_Visibility_Layer.position = offset
	$Masked_Entity_Layer.position = offset
	
	global_position = lerp(global_position, player.global_position, cam_smooth * delta)
