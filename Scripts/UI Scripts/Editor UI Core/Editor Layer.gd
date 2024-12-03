extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var core_tile_importer : TileImporter

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO

var dragging_mouse_point : Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		visible = !visible
		player.editor_open = visible
		player.visible = !visible
		player.collision_body.disabled = player.collision_body.disabled

func LevelPanePressed(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("Editor Secondary"):
			player.position += (dragging_mouse_point - get_viewport().get_mouse_position()) / 2
			dragging_mouse_point = get_viewport().get_mouse_position()
	
	if event.is_pressed(): mouse_position = level_tilemap_root.get_local_mouse_position()
	
	if event.is_action("Editor Secondary") &&event.is_pressed():
		dragging_mouse_point = get_viewport().get_mouse_position()
	
	if event.is_action("Editor Primary") && event.is_pressed():
		var current_layer_button = layer_button_group.get_pressed_button()
		
		if !current_layer_button: return
		
		mouse_position = level_tilemap_root.get_local_mouse_position()
		var selected_tile : Node2D = level_tilemap_root.GetTileByPixel(mouse_position, current_layer_button.select_layer)
		
		if !selected_tile: return
		
		selected_tile.visible = !selected_tile.visible
		return
