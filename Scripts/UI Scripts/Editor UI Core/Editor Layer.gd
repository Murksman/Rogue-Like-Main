extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var core_tile_importer : TileImporter

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		visible = !visible
		player.editor_open = visible
		player.visible = !visible

func LevelPanePressed(event):
	var current_layer_button = layer_button_group.get_pressed_button()
	
	if !current_layer_button: return
	
	mouse_position = level_tilemap_root.get_local_mouse_position()
	var selected_tile : Node2D = level_tilemap_root.GetTileByPixel(mouse_position, current_layer_button.select_layer)
	
	if !selected_tile: return
	
	selected_tile.visible = !selected_tile.visible
