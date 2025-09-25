extends CanvasLayer

@export var player : CharacterBody2D
@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var import_window : Window
@export var level_load_window : Window 
@export var level_save_window : Window 
@export var library_grid : GridContainer
@export var library_tray : Control
@export var toolbar : Control
@export var eraser : TextureButton
@export var tile_selection_outline : NinePatchRect
@export var entity_selection_outline : Control
@export var property_master : Control
@export var tile_tray : Control
@export var enemy_pool_tray : Control
@export var enemy_pool_editor : Window

var mouse_position : Vector2 = Vector2.ZERO
var anchor_mouse_point : Vector2 = Vector2.ZERO
var anchor_tile_point : Vector2i = Vector2i.ZERO

var selected_boxel : UIBoxel
var hover_boxel : UIBoxel

var mouse_pressed : bool
var drag_action_position : Vector2i
var editing : bool = false

var focus_boxel : bool = false

var current_level_filepath : String = ""
var current_level_name : String = ""

var boxel_name_list : PackedStringArray = []
var boxel_id_list : PackedInt32Array = []
var map_object_list : Array[LvlObject] = []

var glove_selection : Object
var glove_select_pos : Vector2
var selected_world_obj : Node2D
var selected_enemy_pool : Control

var tool : int = -1

@onready var window_center = Vector2(DisplayServer.window_get_size()) / 2

func _ready() -> void:
	visible = editing
	LevelInfo.editor_ref = self
	
	LoadResources()

func pseudoProcess(delta):
	if selected_world_obj:
		entity_selection_outline.global_position = window_center - Vector2(32,32) + ((selected_world_obj.global_position - player.camera.global_position) * player.camera.zoom)

func LoadResources() -> void:
	level_tilemap_root.LoadResources()
	
	map_object_list = level_tilemap_root.loaded_object_list
	
	boxel_id_list.resize(map_object_list.size())
	boxel_name_list.resize(map_object_list.size())
	
	for i in map_object_list.size():
		var boxel = map_object_list[i]
		boxel_id_list[i] = boxel.id
		boxel_name_list[i] = boxel.name + ".res"
		library_grid.AddNewBoxel(boxel, SceneLoadingContainer.lvlobject_load_path + "/" + boxel_name_list[i], true)
	
	library_grid.ReorderBoxels()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"): EditToggle(!editing)
	
	if !editing: return
	if event.is_action_pressed("Editor Pencil Tool"): set_tool_mode(0)
	if event.is_action_pressed("Editor Shape Tool"): set_tool_mode(1)
	if event.is_action_pressed("Editor Hollow Tool"): set_tool_mode(2)
	if event.is_action_pressed("Editor Glove Tool"): set_tool_mode(3)
	
	if event.is_action_pressed("Editor Layer Switch"):
		if layer_button_group.get_pressed_button(): 
			var layer_int = (layer_button_group.get_pressed_button().layer_int + 1) % 6
			for layer_button in layer_button_group.get_buttons(): 
				layer_button.set_pressed_no_signal(layer_button.layer_int == layer_int)
			
			layer_button_group.get_buttons()[layer_int]._pressed()
		else:
			for layer_button in layer_button_group.get_buttons(): 
				layer_button.set_pressed_no_signal(layer_button.layer_int == 0)
			
			layer_button_group.get_buttons()[0]._pressed()
	
	if event.is_action_pressed("Save Request"):
		if current_level_filepath == "": RequestSaveLevel()
		else: SaveLevel(current_level_filepath)
	
	if event.is_action_pressed("Delete"): 
		if selected_boxel && focus_boxel:
			selected_boxel.Delete()
			
			var boxel_index = boxel_id_list.find(selected_boxel.boxel.boxel_id)
			boxel_id_list.remove_at(boxel_index)
			boxel_name_list.remove_at(boxel_index)
			selected_boxel = null
			focus_boxel = false
		elif !focus_boxel && selected_world_obj:
			level_tilemap_root.DeleteEntity(selected_world_obj)
			entity_selection_outline.visible = false
			selected_world_obj = null
	
	if event.is_action_pressed("Eraser Mode Toggle"): eraser.set_pressed_no_signal(!eraser.pressed) 

func EditToggle(toggle : bool):
	if toggle: EditorReady()
	else: 
		if EditorExit(): return
	
	editing = toggle
	$"../Global Lighting".visible = !editing
	visible = editing
	player.editor_open = editing
	player.visible = !editing
	player.collision_body.disabled = editing
	level_tilemap_root.layer_groups[5].visible = editing

func EditorExit() -> bool:
	if current_level_filepath != "":
		SaveLevel(current_level_filepath)
	else:
		RequestSaveLevel()
		return true
	
	import_window.notification(NOTIFICATION_WM_CLOSE_REQUEST)
	level_tilemap_root.ResetLayerVisibility()
	
	if current_level_filepath != "":
		level_tilemap_root.SpawnAllEnemies()
	
	return false

func EditorReady(): 
	level_tilemap_root.layer_groups[3].material.set_shader_parameter("is_editing", true)
	level_tilemap_root.WipeMap()
	if current_level_filepath != "":
		LoadLevel(current_level_filepath)

func LevelPanePressed(event : InputEvent) -> void:
	tool = toolbar.selected_tool
	
	mouse_position = level_tilemap_root.get_local_mouse_position()
	
	if event.is_action_pressed("Editor Grab", false, true):
		anchor_mouse_point = get_viewport().get_mouse_position()
	elif event.is_action_pressed("Editor Primary") || event.is_action_pressed("Eraser Hold"):
		anchor_tile_point = level_tilemap_root.PixelToTilePosition(mouse_position)
	
	if event is InputEventMouseMotion && Input.is_action_pressed("Editor Grab"):
		var tmp_anchor_point = get_viewport().get_mouse_position()
		player.position += (anchor_mouse_point - tmp_anchor_point) / 2
		anchor_mouse_point = tmp_anchor_point
	
	if Input.is_action_pressed("Editor Grab") || event.is_action_released("Editor Grab", true): return
	if !layer_button_group.get_pressed_button(): return
	
	var selected_layer = layer_button_group.get_pressed_button().layer_int
	tile_selection_outline.visible = (Input.is_action_pressed("Editor Primary") || Input.is_action_pressed("Eraser Hold")) && ((selected_boxel && toolbar.selected_tool > 0 && selected_layer < 3) || (selected_layer == 5 && toolbar.selected_tool > 0)) 
	
	var tile_position = level_tilemap_root.PixelToTilePosition(mouse_position)
	
	if (event is InputEventMouseMotion && Input.is_action_pressed("Eraser Hold")) || event.is_action_pressed("Eraser Hold") || event.is_action_released("Eraser Hold"):
		var layer_canvas : CanvasGroup = level_tilemap_root.layer_groups[selected_layer]
		focus_boxel = false
		
		drag_action_position = tile_position
		MapEraserEvent(tile_position, layer_canvas, event.is_action_released("Eraser Hold"), selected_layer == 2)
	
	if Input.is_action_pressed("Editor Primary", true) || event.is_action_pressed("Editor Primary", false, true) || event.is_action_released("Editor Primary", true):
		var layer_canvas : CanvasGroup = level_tilemap_root.layer_groups[selected_layer]
		
		if selected_layer > 2:
			if (Input.is_action_pressed("Editor Primary") || event.is_action_released("Primary", true)) && selected_layer == 5:
				if drag_action_position == tile_position && !Input.is_action_just_pressed("Editor Primary") && !event.is_action_released("Editor Primary"): return
				drag_action_position = tile_position
				
				MapEnemyMaskEvent(selected_enemy_pool.enemy_pool, tile_position, eraser.button_pressed, event.is_action_released("Editor Primary") && !Input.is_action_just_released("Editor Grab"))
				return
			
			if event.is_action_pressed("Editor Primary"):
				MapObjectEvent(selected_boxel, mouse_position, layer_canvas)
			
			return
		
		if (selected_boxel && selected_boxel.boxel.layers.has(selected_layer)) || eraser.button_pressed:
			
			if drag_action_position == tile_position && !Input.is_action_just_pressed("Editor Primary") && !event.is_action_released("Editor Primary"): return
			
			focus_boxel = false
			drag_action_position = tile_position
			
			if eraser.button_pressed:
				MapEraserEvent(tile_position, layer_canvas, event.is_action_released("Editor Primary"), selected_layer == 2)
			else:
				MapEditEvent(selected_boxel.boxel, tile_position, layer_canvas, event.is_action_released("Editor Primary") && !Input.is_action_just_released("Editor Grab"))

func MapObjectEvent(lvl_obj : UIBoxel, click_position : Vector2, layer_canvas : CanvasGroup) -> void:
	if tool == 1:
		if !lvl_obj: return
		
		var entity = level_tilemap_root.AddEntity(lvl_obj.boxel.obj_type, layer_canvas, click_position - Vector2(16.0, 16.0))
		SelectObject(entity)
	elif tool == 4:
		var closest = level_tilemap_root.GetNearestObjects(layer_canvas, mouse_position, 100.0, true)[0]
		if !closest: return
		
		SelectObject(closest)

func MapEditEvent(boxel : LvlObject, tile_position : Vector2i, layer_canvas : CanvasGroup, released : bool) -> void:
	var tool = toolbar.selected_tool
	
	if tool == 1:
		tile_selection_outline.global_position = tile_position * 64 - Vector2i(player.camera.global_position * 2) + Vector2i(get_viewport().get_visible_rect().size / 2)
		tile_selection_outline.size = Vector2i(64,64)
		var check_chunks_err : int = level_tilemap_root.CheckSetMapSize(tile_position)
		if check_chunks_err != 0: printerr("Chunk Checker Error - ", check_chunks_err)
		
		level_tilemap_root.AddTile(selected_boxel.boxel, tile_position, layer_canvas)
		return
	
	var shape_position = Vector2i(min(anchor_tile_point.x, tile_position.x), min(anchor_tile_point.y, tile_position.y))
	var shape_size : Vector2i = abs(anchor_tile_point - tile_position) + Vector2i(1,1)
	var shape_rect = Rect2i(shape_position, shape_size)
	tile_selection_outline.size = shape_size * 64
	tile_selection_outline.global_position = shape_position * 64 - Vector2i(player.camera.global_position * 2) + Vector2i(get_viewport().get_visible_rect().size / 2)
	
	if !released: return
	
	var check_chunks_err : int = level_tilemap_root.CheckSetMapSize(tile_position)
	if check_chunks_err != 0: 
		printerr("Chunk Checker Error - ", check_chunks_err)
		return
	check_chunks_err = level_tilemap_root.CheckSetMapSize(anchor_tile_point)
	if check_chunks_err != 0: 
		printerr("Chunk Checker Error - ", check_chunks_err)
		return
	
	if tool == 2:
		level_tilemap_root.ShapeTool(shape_rect, layer_canvas, selected_boxel.boxel)
	elif tool == 3:
		level_tilemap_root.ShapeTool(shape_rect, layer_canvas, selected_boxel.boxel, true)

func MapEraserEvent(tile_position : Vector2i, layer_canvas : CanvasGroup, released : bool, update_adjacent : bool = true) -> void:
	var tool = toolbar.selected_tool
	
	if tool == 1:
		tile_selection_outline.global_position = tile_position
		
		if !level_tilemap_root.CheckMapSize(tile_position): return
		
		level_tilemap_root.EraseAtPosition(tile_position, layer_canvas, update_adjacent)
		return
	
	var shape_position = Vector2i(min(anchor_tile_point.x, tile_position.x), min(anchor_tile_point.y, tile_position.y))
	var shape_size : Vector2i = abs(anchor_tile_point - tile_position) + Vector2i(1,1)
	var shape_rect = Rect2i(shape_position, shape_size)
	tile_selection_outline.size = shape_size * 64
	tile_selection_outline.global_position = shape_position * 64 - Vector2i(player.camera.global_position * 2) + Vector2i(get_viewport().get_visible_rect().size / 2)
	
	if !released: return
	if !level_tilemap_root.CheckMapSize(anchor_tile_point): return
	if !level_tilemap_root.CheckMapSize(tile_position): return
	
	if tool == 2:
		level_tilemap_root.EraserShapeTool(shape_rect, layer_canvas)
	elif tool == 3:
		level_tilemap_root.EraserShapeTool(shape_rect, layer_canvas, true)

func MapEnemyMaskEvent(enemy_pool : EnemyPool, tile_position : Vector2i, erasing : bool, released : bool):
	var tool = toolbar.selected_tool
	
	if tool == 1:
		tile_selection_outline.global_position = tile_position * 64 - Vector2i(player.camera.global_position * 2) + Vector2i(get_viewport().get_visible_rect().size / 2)
		
		if erasing: 
			if !level_tilemap_root.CheckMapSize(tile_position): return
			level_tilemap_root.EraseAtPosition(tile_position, level_tilemap_root.layer_groups[5], false)
		else: 
			if level_tilemap_root.CheckSetMapSize(tile_position) != 0: return
			level_tilemap_root.AddEnemyMaskTile(tile_position, enemy_pool)
		return
	
	if tool != 2 && tool != 3: return
	
	var shape_position = Vector2i(min(anchor_tile_point.x, tile_position.x), min(anchor_tile_point.y, tile_position.y))
	var shape_size : Vector2i = abs(anchor_tile_point - tile_position) + Vector2i(1,1)
	var shape_rect = Rect2i(shape_position, shape_size)
	tile_selection_outline.size = shape_size * 64
	tile_selection_outline.global_position = shape_position * 64 - Vector2i(player.camera.global_position * 2) + Vector2i(get_viewport().get_visible_rect().size / 2)
	
	if !released: return
	
	if erasing:
		if !level_tilemap_root.CheckMapSize(anchor_tile_point): return
		if !level_tilemap_root.CheckMapSize(tile_position): return
		level_tilemap_root.EnemyMaskShapeEraser(shape_rect)
	else:
		if level_tilemap_root.CheckSetMapSize(anchor_tile_point) != 0: return
		if level_tilemap_root.CheckSetMapSize(tile_position) != 0: return
		level_tilemap_root.EnemyMaskShapeTool(shape_rect, enemy_pool)

func SelectBoxel(target_boxel : UIBoxel) -> void:
	if target_boxel == selected_boxel:
		target_boxel.tile_highlighter.visible = false
		selected_boxel = null
		focus_boxel = false
		return
	
	focus_boxel = true
	
	if selected_boxel: selected_boxel.tile_highlighter.visible = false
	
	target_boxel.tile_highlighter.visible = true
	selected_boxel = target_boxel

func MouseExit(target : Control):
	if target == hover_boxel:
		hover_boxel.name_text.visible = false
		hover_boxel = null

func HoverBoxel(hover_target : UIBoxel):
	if hover_boxel && hover_target != hover_boxel: 
		hover_boxel.name_text.visible = false
	hover_boxel = hover_target
	hover_target.name_text.visible = true

func RequestSaveLevel():
	level_save_window.popup()
	level_save_window.visible = true
	level_save_window.WindowReady(current_level_filepath)

func SaveLevel(filepath : String):
	current_level_filepath = filepath
	current_level_name = filepath.get_file().split(".")[0]
	
	if filepath.get_extension() == "dat":
		level_tilemap_root.WriteLevelFile(filepath, current_level_name, enemy_pool_tray)
	else:
		level_tilemap_root.AssignTileOwner()
		
		var new_level_save = PackedScene.new()
		new_level_save.pack(level_tilemap_root.level_save_root)
		
		var save_err = ResourceSaver.save(new_level_save, filepath)

func LoadLevel(filepath : String, instant_start : bool = false) -> void:
	current_level_filepath = filepath
	current_level_name = filepath.get_file().split(".")[0]
	
	if filepath.get_extension() == "dat":
		level_tilemap_root.ReadLevelFile(filepath)
		
		if instant_start:
			for pool in enemy_pool_tray.get_children():
				level_tilemap_root.SpawnAllEnemiesInPool(pool.enemy_pool)
	else:
		printerr("Level Loading Error - Invalid file type.")
		return
		
		var level_load = ResourceLoader.load(filepath, "PackedScene")
		var new_level = level_load.instantiate()
		level_tilemap_root.level_save_root.queue_free()
		
		level_tilemap_root.add_child(new_level)
		level_tilemap_root.level_save_root = new_level
		new_level.position = Vector2(16,16)
		for i in 5:
			level_tilemap_root.layer_groups[i] = new_level.get_child(i)
			$"Editor UI/Top Editor Bar/Layer Bar Container".get_child(i).select_layer = new_level.get_child(i)
		
		level_tilemap_root.ResizeMapBounds()
		level_tilemap_root.ResetMap()

func RequestLoadLevel() -> void:
	level_load_window.popup()
	level_load_window.visible = true
	level_load_window.WindowReady()

func EditBoxel(boxel : LvlObject) -> void:
	import_window.SetImporterMode(true, boxel)
	import_window.popup()
	import_window.visible = true
	import_window.WindowReady()
	
	SelectObject(null)

func ImporterAddBoxel(boxel : LvlObject) -> void:
	var new_index = map_object_list.bsearch_custom(boxel, func(b1,b2): return b1.boxel_id < b2.boxel_id)
	map_object_list.insert(new_index, boxel)
	boxel_id_list.append(boxel.boxel_id)
	boxel_name_list.append(boxel.resource_path.get_file())

func SelectObject(world_object : Node2D) -> void:
	focus_boxel = false
	
	if selected_world_obj == world_object:
		selected_world_obj = null
		
		property_master.visible = false
	else:
		if world_object && !(world_object is Entity): printerr("Attempting to select an Object of invalid type: ", world_object.name)
		else: 
			selected_world_obj = world_object
			property_master.visible = true
	
	if selected_world_obj: property_master.Reset(selected_world_obj)
	entity_selection_outline.visible = selected_world_obj != null

func ChangeLayer(layer_int : int) -> void:
	var is_enemy_layer = layer_int == 5
	
	enemy_pool_tray.visible = is_enemy_layer
	tile_tray.visible = !is_enemy_layer
	library_tray.visible = !is_enemy_layer
	
	if selected_world_obj: SelectObject(selected_world_obj)
	library_grid.ReorderBoxels()
	
	if layer_int > 2 && layer_int < 5:
		if tool == 2 || tool == 3: 
			tool = -1
			toolbar.selected_tool = -1
		
		toolbar.get_child(1).visible = false
		toolbar.get_child(2).visible = false
	else:
		toolbar.get_child(1).visible = true
		toolbar.get_child(2).visible = true

func set_tool_mode(idx : int):
	for i in 4: toolbar.blend_buttons[i].set_pressed_no_signal(false)
	toolbar.blend_buttons[idx].set_pressed_no_signal(true)
	toolbar.blend_buttons[idx].toggled.emit()
	tool = idx + 1
	toolbar.selected_tool = tool

func OpenEnemyPool(pool : EnemyPool):
	enemy_pool_editor.Open(pool)

func NewLevel(filepath : String = ""):
	level_tilemap_root.WipeMap()
	current_level_filepath = filepath
	current_level_name = filepath.get_file().split(".")[0]
	
	if filepath != "":
		SaveLevel(filepath)

func _on_editor_import_button_pressed() -> void:
	import_window.SetImporterMode(false)
	import_window.popup()
	import_window.visible = true
	import_window.WindowReady()

func _on_editor_exit_button_pressed() -> void:
	EditToggle(false)

func _on_save_level() -> void:
	RequestSaveLevel()

func _on_load_level_button_pressed() -> void:
	RequestLoadLevel()
