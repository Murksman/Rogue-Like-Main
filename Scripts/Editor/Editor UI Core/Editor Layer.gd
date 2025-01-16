extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var import_window : Window
@export var library_grid : GridContainer

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO
var anchor_mouse_point : Vector2

var selected_boxel : UIBoxel
var hover_boxel : UIBoxel

var drag_action_tile : Node
var drag_action_position : Vector2i
var editing : bool = false

func _ready() -> void:
	LevelInfo.editor_ref = self
	
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
	pass

func LevelPanePressed(event : InputEvent) -> void:
	if event is InputEventMouseMotion || event.is_action("Editor Primary"):
		if Input.is_action_pressed("Editor Secondary"):
			player.position += (anchor_mouse_point - get_viewport().get_mouse_position()) / 2
			anchor_mouse_point = get_viewport().get_mouse_position()
			
		elif Input.is_action_pressed("Editor Primary") && layer_button_group.get_pressed_button() && selected_boxel:
			var global_mouse_pos = level_tilemap_root.get_local_mouse_position()
			var selected_layer = layer_button_group.get_pressed_button().layer_int
			var layer_canvas : CanvasGroup = level_tilemap_root.layer_groups[selected_layer]
			
			var tile_position = level_tilemap_root.PixelToTilePosition(global_mouse_pos)
			
			var check_chunks_err = level_tilemap_root.CheckSetMapSize(tile_position)
			
			if drag_action_position != tile_position:
				print(selected_boxel.boxel is ScatterBoxel)
				drag_action_tile = level_tilemap_root.AddTile(selected_boxel.boxel, tile_position, layer_canvas)
				drag_action_position = tile_position
	
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

func SelectBoxel(target_boxel : UIBoxel) -> void:
	if target_boxel == selected_boxel:
		target_boxel.tile_highlighter.visible = false
		selected_boxel = null
		return
	
	if selected_boxel: selected_boxel.tile_highlighter.visible = false
	
	target_boxel.tile_highlighter.visible = true
	selected_boxel = target_boxel

func MouseExit(target : Control):
	if target == hover_boxel:
		hover_boxel.name_label.visible = false
		hover_boxel = null

func HoverBoxel(hover_target : UIBoxel):
	if hover_boxel && hover_target != hover_boxel: 
		hover_boxel.name_label.visible = false
	hover_boxel = hover_target
	hover_target.name_label.visible = true

func _on_editor_import_button_pressed() -> void:
	import_window.popup()
	import_window.visible = true
	import_window.WindowReady()


func _on_editor_exit_button_pressed() -> void:
	EditToggle(false)
