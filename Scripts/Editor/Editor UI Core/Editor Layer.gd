extends CanvasLayer

@export var level_tilemap_root : Node2D
@export var layer_button_group : ButtonGroup
@export var import_window : Window
@export var level_load_window : Window 
@export var level_save_window : Window 
@export var library_grid : GridContainer
@export var toolbar : Control
@export var eraser : TextureButton

@onready var player : CharacterBody2D = $"../Player"

var mouse_position : Vector2 = Vector2.ZERO
var anchor_mouse_point : Vector2 = Vector2.ZERO
var anchor_drag_point : Vector2 = Vector2.ZERO

var selected_boxel : UIBoxel
var hover_boxel : UIBoxel

var mouse_pressed : bool
var drag_action_position : Vector2i
var editing : bool = false

var current_level_filepath : String
var current_level_name : String

var boxel_name_list : PackedStringArray = []
var boxel_id_list : PackedInt32Array = []
var map_boxel_list : Array[Boxel] = []

func _ready() -> void:
	visible = !editing
	LevelInfo.editor_ref = self
	
	LoadBoxels()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"): EditToggle(!editing)
	if event.is_action_pressed("Save Request"): 
		if current_level_filepath != "":
			SaveLevel(current_level_filepath)
		else:
			RequestSaveLevel()
	
	if event.is_action_pressed("Delete") && selected_boxel:
		selected_boxel.Delete()
		
		var boxel_index = boxel_id_list.find(selected_boxel.boxel.boxel_id)
		boxel_id_list.remove_at(boxel_index)
		boxel_name_list.remove_at(boxel_index)
		selected_boxel = null
	
	if event.is_action_pressed("Eraser Mode"): eraser.set_pressed_no_signal(!eraser.pressed) 

func EditToggle(force_toggle : bool):
	editing = force_toggle
	
	$"../Global Lighting".visible = !editing
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
	mouse_position = level_tilemap_root.get_local_mouse_position()
	
	if event.is_action_pressed("Editor Secondary"):
		anchor_mouse_point = get_viewport().get_mouse_position()
	
	if event.is_action_pressed("Editor Primary"):
		anchor_drag_point = get_viewport().get_mouse_position()
	
	if event is InputEventMouseMotion && Input.is_action_pressed("Editor Secondary"):
		var tmp_anchor_point = get_viewport().get_mouse_position()
		player.position += (anchor_mouse_point - tmp_anchor_point) / 2
		anchor_mouse_point = tmp_anchor_point
	
	if !event.is_action("Editor Primary") && !(event is InputEventMouseMotion && Input.is_action_pressed("Editor Primary")): return
	if !layer_button_group.get_pressed_button(): return
	
	var selected_layer = layer_button_group.get_pressed_button().layer_int
	
	if (selected_boxel && selected_boxel.boxel.layers.has(selected_layer)) || eraser.button_pressed:
		var tile_position = level_tilemap_root.PixelToTilePosition(mouse_position)
		if drag_action_position == tile_position && !Input.is_action_just_pressed("Editor Primary"): return
		
		var check_chunks_err : int = level_tilemap_root.CheckSetMapSize(tile_position)
		if check_chunks_err != 0: print("Chunk Checker Error - ", check_chunks_err)
		
		var layer_canvas : CanvasGroup = level_tilemap_root.layer_groups[selected_layer]
		
		if eraser.button_pressed:
			MapEraserEvent(tile_position, layer_canvas, event.is_action_released("Editor Primary"))
		else:
			MapEditEvent(selected_boxel.boxel, tile_position, layer_canvas, event.is_action_released("Editor Primary"))
		
		drag_action_position = tile_position

func MapEditEvent(boxel : Boxel, tile_position : Vector2i, layer_canvas : CanvasGroup, released : bool) -> void:
	var tool = toolbar.selected_tool
	
	if tool == 1:
		level_tilemap_root.AddTile(selected_boxel.boxel, tile_position, layer_canvas)
	elif tool == 2:
		if released:
			level_tilemap_root.ShapeTool(tile_position, layer_canvas, selected_boxel.boxel)
	elif tool == 3:
		if released:
			pass

func MapEraserEvent(tile_position : Vector2i, layer_canvas : CanvasGroup, released : bool) -> void:
	var tool = toolbar.selected_tool
	
	if tool == 1:
		level_tilemap_root.EraseAtPosition(tile_position, layer_canvas)
	elif tool == 2:
		if released:
			level_tilemap_root.EraserShapeTool(tile_position, layer_canvas)
	elif tool == 3:
		if released:
			pass
	

func LoadBoxels() -> void:
	level_tilemap_root.LoadBoxels()
	
	map_boxel_list = level_tilemap_root.loaded_boxel_list
	
	boxel_id_list.resize(map_boxel_list.size())
	boxel_name_list.resize(map_boxel_list.size())
	
	for i in map_boxel_list.size():
		var boxel = map_boxel_list[i]
		boxel_id_list[i] = boxel.boxel_id
		boxel_name_list[i] = boxel.boxel_name + ".res"
		library_grid.AddNewBoxel(boxel, SceneLoadingContainer.boxel_load_path + "/" + boxel_name_list[i], true)
	
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
		WriteLevelFile(filepath)
	else:
		level_tilemap_root.AssignTileOwner()
		
		var new_level_save = PackedScene.new()
		new_level_save.pack(level_tilemap_root.level_save_root)
		
		var save_err = ResourceSaver.save(new_level_save, filepath)

func LoadLevel(filepath : String) -> void:
	current_level_filepath = filepath
	current_level_name = filepath.get_file().split(".")[0]
	
	if filepath.get_extension() == "dat":
		ReadLevelFile(filepath)
	else:
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

func ReadLevelFile(filepath : String):
	var file = FileAccess.open(filepath, FileAccess.READ)
	var lvl_namesize = file.get_8()
	var lvl_name = file.get_buffer(lvl_namesize)
	file.seek(file.get_position() + 2)
	
	var chunks_size : Vector2i = Vector2i(0,0)
	chunks_size.x = file.get_32()
	chunks_size.y = file.get_32()
	level_tilemap_root.WipeMapTiles(chunks_size)
	
	var map_size = chunks_size * level_tilemap_root.chunk_size
	level_tilemap_root.map_size = map_size
	level_tilemap_root.chunk_origin = Vector2i(0,0)
	level_tilemap_root.bounds_offset = Vector2i(0,0)
	file.seek(file.get_position() + 1)
	
	var id_list_size = file.get_32()
	var id_list_buffer : PackedByteArray = file.get_buffer(id_list_size)
	
	level_tilemap_root.boxel_id_list.resize(id_list_size >> 2)
	level_tilemap_root.boxel_usage_list.resize(id_list_size >> 2)
	level_tilemap_root.boxel_usage_list.fill(0)
	
	for i in id_list_size >> 2:
		level_tilemap_root.boxel_id_list[i] = id_list_buffer.decode_u32(i << 2)
	
	file.seek(file.get_position() + 1)
	
	var temp_boxel_load_list : Array[Boxel] = []
	temp_boxel_load_list.resize(boxel_id_list.size())
	
	for i in boxel_id_list.size():
		var temp_id = boxel_id_list[i]
		var dummy_boxel = Boxel.new()
		dummy_boxel.boxel_id = temp_id
		var new_index = map_boxel_list.bsearch_custom(dummy_boxel, func(a, b): return a.boxel_id < b.boxel_id)
		
		temp_boxel_load_list[i] = map_boxel_list[new_index]
	
	var map_array_length = file.get_64()
	file.seek(file.get_position() + 1)
	
	for layer in level_tilemap_root.layer_groups:
		var floor_tile_buff : PackedByteArray = file.get_buffer(map_array_length)
		var read_result = level_tilemap_root.ReadPackedTileArray(layer, floor_tile_buff, temp_boxel_load_list)
		
		if read_result != "": printerr(read_result)
		file.seek(file.get_position() + 1)

func WriteLevelFile(filepath : String, filename : String = current_level_name):
	var file = FileAccess.open(filepath, FileAccess.WRITE_READ)
	file.resize(0)
	
	var filename_buff := filename.to_utf8_buffer()
	file.store_8(filename_buff.size())
	file.store_buffer(filename_buff)
	file.store_string("\n")
	
	## Metadata TBD
	file.store_string("\n")
	
	file.store_32(level_tilemap_root.chunk_dimensions.x)
	file.store_32(level_tilemap_root.chunk_dimensions.y)
	file.store_string("\n")
	
	var boxel_id_buffer : PackedByteArray = level_tilemap_root.boxel_id_list.to_byte_array()
	
	file.store_32(boxel_id_buffer.size())
	file.store_buffer(boxel_id_buffer)
	file.store_string("\n")
	
	var map_array_length : int = level_tilemap_root.chunk_dimensions.x * level_tilemap_root.chunk_dimensions.y * level_tilemap_root.chunk_size * level_tilemap_root.chunk_size
	file.store_64(map_array_length)
	file.store_string("\n")
	
	for layer in level_tilemap_root.layer_groups:
		var floor_tile_buff : PackedByteArray = level_tilemap_root.GetPackedTileArray(layer, map_array_length)
		
		file.store_buffer(floor_tile_buff)
		file.store_string("\n")
	file.store_string("\n")
	

func RequestLoadLevel() -> void:
	level_load_window.popup()
	level_load_window.visible = true
	level_load_window.WindowReady()

func EditBoxel(boxel : Boxel) -> void:
	import_window.SetImporterMode(true, boxel)
	import_window.popup()
	import_window.visible = true
	import_window.WindowReady()

func ImporterAddBoxel(boxel : Boxel) -> void:
	var new_index = map_boxel_list.bsearch_custom(boxel, func(b1,b2): return b1.boxel_id < b2.boxel_id)
	map_boxel_list.insert(new_index, boxel)
	boxel_id_list.append(boxel.boxel_id)
	boxel_name_list.append(boxel.resource_path.get_file())

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
