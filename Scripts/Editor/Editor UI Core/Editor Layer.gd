extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var core_tile_importer : TileImporter

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO
var anchor_mouse_point : Vector2

var selected_boxel : UIBoxel

var drag_action_tile : Node
var editing 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		editing = !editing
		visible = editing
		player.editor_open = editing
		player.visible = !editing
		player.collision_body.disabled = editing
		
		if layer_button_group.get_pressed_button(): layer_button_group.get_pressed_button().button_pressed = false
		level_tilemap_root.ResetLayerVisibility()

func LevelPanePressed(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("Editor Secondary"):
			player.position += (anchor_mouse_point - get_viewport().get_mouse_position()) / 2
			anchor_mouse_point = get_viewport().get_mouse_position()
			
		elif Input.is_action_pressed("Editor Primary") && layer_button_group.get_pressed_button() && selected_boxel:
			var global_mouse_pos = level_tilemap_root.get_local_mouse_position()
			var temp_sampled_tile = level_tilemap_root.GetTileByPixel(global_mouse_pos, layer_button_group.get_pressed_button().select_layer)
			
			if drag_action_tile != temp_sampled_tile: 
				drag_action_tile = level_tilemap_root.AddTile(selected_boxel.boxel.GetTileInfo(), global_mouse_pos, layer_button_group.get_pressed_button().select_layer)
	
	if event.is_pressed(): mouse_position = level_tilemap_root.get_local_mouse_position()
	
	if event.is_action("Editor Secondary") &&event.is_pressed():
		anchor_mouse_point = get_viewport().get_mouse_position()
	
	#if event.is_action("Editor Primary") && event.is_pressed():
		#var current_layer_button = layer_button_group.get_pressed_button()
		#
		#if !current_layer_button: return
		#
		#mouse_position = level_tilemap_root.get_local_mouse_position()
		#var selected_tile : Node2D = level_tilemap_root.GetTileByPixel(mouse_position, current_layer_button.select_layer)
		#
		#if !selected_tile: return
		#
		#selected_tile.visible = !selected_tile.visible
		#return
