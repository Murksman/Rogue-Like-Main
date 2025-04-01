extends Window

@export var open_file_handler : FileDialog
@export var editor_master : CanvasLayer
@export var error_popup : AcceptDialog
@export var error_popup_text : Label

@export_group("Boxel Import | Edit Controls")
@export var importing_label : Label
@export var editing_label : Label
@export_group("Boxel Image Controls")
@export var filepath_text : LineEdit
@export var preview_image : TextureRect
@export_group("Boxel Info Controls")
@export var boxelname_text : LineEdit
@export var boxel_type_selection : Array[CheckBox]
@export var boxel_layer_selection : Array[CheckBox]
@export var boxel_type_group : ButtonGroup
@export_group("Boxel Normal Controls")
@export var normals_tab_control : Control
@export var normal_image : TextureRect
@export var normalpath_text : LineEdit

var imported_src_image : Image
var imported_src_normal : Image
var imported_image_tex : ImageTexture
var imported_normal_tex : ImageTexture

var queue_import_time : int = 0
var importing := true
var editing_boxel : Boxel = null

var open_file_paths : Array[String] = []
var selected_layers : Array[int] = []

@onready var rng = RandomNumberGenerator.new()

func _process(delta: float) -> void:
	if queue_import_time > 0:
		queue_import_time -= 1
		if queue_import_time == 0: open_file_handler.RequestOpen(self, false)

func WindowReady() -> void:
	if !preview_image.texture: queue_import_time = 2

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		visible = false

func _input(event: InputEvent) -> void:
	if event.is_action("Escape"): 
		notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		hide()
		editor_master.EditToggle(false)

func SetImporterMode(editing : bool = false, edit_boxel : Boxel = null) -> void:
	print("SetImporterMode - ", editing)
	
	for layer in boxel_layer_selection:
		layer.set_pressed_no_signal(false)
	for type in boxel_type_selection:
		type.set_pressed_no_signal(false)
	
	if editing:
		editing_boxel = edit_boxel
		
		importing_label.visible = false
		editing_label.visible = true
		
		filepath_text.text = "No Path Selected."
		normalpath_text.text = "No Path Selected."
		print("testing SetImporterMode")
		var full_texture : CanvasTexture = edit_boxel.StitchFullTexture()
		print("Full Texture - ", full_texture.diffuse_texture.get_class())
		preview_image.texture = full_texture.diffuse_texture
		imported_image_tex = full_texture.diffuse_texture
		normal_image.texture = full_texture.normal_texture
		imported_normal_tex = full_texture.normal_texture
		boxelname_text.text = edit_boxel.boxel_name
		print("Full Texture - ", preview_image.texture)
		
		for i in edit_boxel.layers:
			boxel_layer_selection[i].set_pressed_no_signal(true)
		
		if edit_boxel is UnitBoxel: 
			boxel_type_selection[0].set_pressed_no_signal(false)
		elif edit_boxel is ConnectorBoxel: 
			boxel_type_selection[1].set_pressed_no_signal(false)
		elif edit_boxel is ScatterBoxel: 
			boxel_type_selection[2].set_pressed_no_signal(false)
	else:
		importing_label.visible = true
		editing_label.visible = false
		
		filepath_text.text = "No Path Selected."
		normalpath_text.text = "No Path Selected."
		preview_image.texture = null
		imported_image_tex = null
		normal_image.texture = null
		imported_normal_tex = null
		boxelname_text.text = ""
	
	importing = !editing

func FileImportCatch(files : Array[String], is_normal : bool) -> void:
	open_file_paths = files
	var pre_load = false
	
	if is_normal:
		var filepath = files[0]
		if filepath.get_extension() == "tres" || filepath.get_extension() == "res":
			var image_resource = ResourceLoader.load(filepath, "Image")
			if image_resource is ImageTexture || image_resource is Image:
				imported_normal_tex = image_resource
				pre_load = true
			else: printerr("FileImportCatch Error: Invalid File Type!")
		else:
			imported_src_normal = Image.load_from_file(filepath)
		
		if imported_src_image && imported_src_normal.get_size() != imported_src_image.get_size():
			ErrorPop("Imported Boxel Image and Normal image must have the same size.")
			imported_src_normal = null
			return
		
		UpdateNormalSettings(pre_load)
	else:
		var filepath = files[0]
		if filepath.get_extension() == "tres" || filepath.get_extension() == "res":
			var image_resource = ResourceLoader.load(filepath, "Image")
			if image_resource is ImageTexture:
				imported_image_tex = image_resource
				pre_load = true
			else: printerr("FileImportCatch Error: Invalid File Type!")
		else:
			imported_src_image = Image.load_from_file(filepath)
		
		UpdateImageSettings(pre_load)

func UpdateImageSettings(pre_load : bool = false):
	if !pre_load: imported_image_tex = ImageTexture.create_from_image(imported_src_image)
	
	filepath_text.text = open_file_paths[0]
	preview_image.texture = imported_image_tex

func UpdateNormalSettings(pre_load : bool = false):
	if !pre_load: imported_normal_tex = ImageTexture.create_from_image(imported_src_normal)
	
	normalpath_text.text = open_file_paths[0]
	normal_image.texture = imported_normal_tex

func ValidateImport():
	var selected_type : int = -1
	if boxel_type_group.get_pressed_button(): selected_type = boxel_type_group.get_pressed_button().get_meta("type_index")
	
	selected_layers = []
	for layer_button in boxel_layer_selection: if layer_button.button_pressed: selected_layers.append(layer_button.get_meta("layer_index")) 
	
	if selected_type == -1: return "Select a boxel type."
	if !imported_image_tex: return "Invalid or missing image."
	if selected_layers.size() == 0: return "Select 1 or more layers for the boxel type."
	if selected_type == 0 && (imported_image_tex.get_size() != Vector2(32,32) || imported_normal_tex.get_size() != Vector2(32,32)):
		return "Images and Normals must be a 32x32 image when importing single boxels."
	if (selected_type == 1 || selected_type == 2) && (imported_image_tex.get_size() != Vector2(128,128) || imported_normal_tex.get_size() != Vector2(128,128)):
		return "Images and Normals must be a 128x128 image when importing connected or scatter boxels."
	
	return 0

func FinishImport():
	var validation_status = ValidateImport()
	if validation_status is String:
		ErrorPop(validation_status)
		return
	
	var selected_type = boxel_type_group.get_pressed_button().get_meta("type_index")
	
	var new_boxel : Boxel
	
	if importing:
		if selected_type == 0: 
			new_boxel = UnitBoxel.new()
		elif selected_type == 1: 
			new_boxel = ConnectorBoxel.new()
		else: 
			new_boxel = ScatterBoxel.new()
		
		while editor_master.boxel_id_list.has(new_boxel.boxel_id) || new_boxel.boxel_id == 0:
			rng.randomize()
			new_boxel.boxel_id = abs(rng.randi())
	
	print("Finish Import - Test boxel id post randomizer: ", new_boxel.boxel_id)
	
	if selected_type == 0:
		var new_tile_info = TileInfo.new()
		
		new_tile_info.image = CanvasTexture.new()
		new_tile_info.image.diffuse_texture = imported_image_tex
		new_tile_info.image.normal_texture = imported_normal_tex
		new_boxel.tile_info = new_tile_info
		new_boxel.boxel_img = new_tile_info.image
	elif selected_type == 1 || selected_type == 2:
		print("Finish Import - Test boxel ID pre Boxel info: ", new_boxel.boxel_id)
		var new_tile_info_array : Array[TileInfo] = []
		var boxel_image_list = GenerateImages()
		var boxel_normal_list = GenerateNormalImages()
		new_tile_info_array.resize(boxel_image_list.size())
		
		print("Finish Import - Test boxel ID pre Boxel image array: ", new_boxel.boxel_id)
		for i in boxel_image_list.size(): 
			var new_tile_info = TileInfo.new()
			new_tile_info.image = CanvasTexture.new()
			new_tile_info.image.diffuse_texture = boxel_image_list[i]
			new_tile_info.image.normal_texture = boxel_normal_list[i]
			new_tile_info_array[i] = new_tile_info
		
		new_boxel.boxel_img = CanvasTexture.new()
		new_boxel.boxel_img.diffuse_texture = new_tile_info_array[0].image.diffuse_texture
		new_boxel.boxel_img.normal_texture = new_tile_info_array[0].image.normal_texture
		new_boxel.tile_array = new_tile_info_array
		print("Finish Import - Test boxel ID post Boxel Info: ", new_boxel.boxel_id)
	
	new_boxel.layers = selected_layers
	new_boxel.boxel_name = StringName(boxelname_text.text)
	
	var load_path = SceneLoadingContainer.SearchGenerateDirPath(SceneLoadingContainer.boxel_load_path + "/" + boxelname_text.text, "res")
	var err = ResourceSaver.save(new_boxel, load_path)
	
	if err == 0:
		if importing: editor_master.ImporterAddBoxel(new_boxel)
		editor_master.library_grid.AddNewBoxel(new_boxel, filepath_text.text, importing)
	else:
		printerr("Failed to save generated Boxel with code: ", err)
	
	visible = false

func GenerateImages() -> Array[ImageTexture]:
	var image_array : Array[ImageTexture] = []
	
	var img : Image = imported_src_image
	
	for y in 4:
		for x in 4:
			var curr_img_pos = Vector2i(x,y) * 32
			var new_img = img.get_region(Rect2i(curr_img_pos, Vector2i(32,32)))
			image_array.append(ImageTexture.create_from_image(new_img))
	
	return image_array

func GenerateNormalImages() -> Array[ImageTexture]:
	var normal_array : Array[ImageTexture] = []
	
	var normal_img : Image = imported_src_normal
	
	for y in 4:
		for x in 4:
			var curr_img_pos = Vector2i(x,y) * 32
			var new_normal_img = normal_img.get_region(Rect2i(curr_img_pos, Vector2i(32, 32)))
			normal_array.append(ImageTexture.create_from_image(new_normal_img))
	
	return normal_array

func ErrorPop(error_code : String):
	error_popup_text.text = "Error: " + error_code
	error_popup.size = Vector2(320,130)
	error_popup.popup()
	error_popup.visible = true

func _on_finish_import_button_pressed() -> void:
	FinishImport()

func _on_files_dropped(files: PackedStringArray) -> void:
	FileImportCatch(files, normals_tab_control.get_global_rect().has_point(get_mouse_position()))

func _on_file_path_button_pressed() -> void:
	open_file_handler.RequestOpen(self, false)

func _on_normal_path_button_pressed() -> void:
	open_file_handler.RequestOpen(self, true)
