extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var core_tile_importer : TileImporter
@export var import_window : Window
@export var library_grid : GridContainer

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO
var anchor_mouse_point : Vector2

var selected_boxel : UIBoxel

var drag_action_tile : Node
var editing : bool = false

func _ready() -> void:
	LoadBoxels()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"): EditToggle(!editing)

func EditToggle(force_toggle : bool):
	editing = force_toggle
	if editing: EditorReady()
	else: EditorExit()
	
	visible = editing
	player.editor_open = editing
	player.visible = !editing
	player.collision_body.disabled = editing
	
	if layer_button_group.get_pressed_button(): layer_button_group.get_pressed_button().button_pressed = false

func EditorExit():
	import_window.notification(NOTIFICATION_WM_CLOSE_REQUEST)
	level_tilemap_root.ResetLayerVisibility()

func EditorReady(): 
	import_window.WindowReady()

func LevelPanePressed(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("Editor Secondary"):
			player.position += (anchor_mouse_point - get_viewport().get_mouse_position()) / 2
			anchor_mouse_point = get_viewport().get_mouse_position()
			
		elif Input.is_action_pressed("Editor Primary") && layer_button_group.get_pressed_button() && selected_boxel:
			var global_mouse_pos = level_tilemap_root.get_local_mouse_position()
			var selected_layer = layer_button_group.get_pressed_button().layer_int
			var layer_canvas : CanvasGroup = level_tilemap_root.layer_groups[selected_layer]
			
			var temp_sampled_tile = level_tilemap_root.GetTileByPixel(global_mouse_pos, layer_canvas)
			
			if drag_action_tile != temp_sampled_tile: 
				drag_action_tile = level_tilemap_root.AddTile(selected_boxel.boxel.GetTileInfo(), global_mouse_pos, layer_canvas)
	
	if event.is_pressed(): mouse_position = level_tilemap_root.get_local_mouse_position()
	
	if event.is_action("Editor Secondary") && event.is_pressed():
		anchor_mouse_point = get_viewport().get_mouse_position()

func LoadBoxels() -> void:
	var boxel_paths = DirAccess.get_files_at("user://Editor Boxels")
	for path in boxel_paths:
		var load_result = ResourceLoader.load("user://Editor Boxels/" + path, "Boxel")
		if load_result is Boxel: library_grid.AddNewBoxel(load_result)
		else: 
			print("Boxel Loading Error Code: ", load_result)
	
	library_grid.ReorderBoxels()

func _on_editor_import_button_pressed() -> void:
	import_window.popup()
	import_window.visible = true
	import_window.WindowReady()


func _on_editor_exit_button_pressed() -> void:
	EditToggle(false)
