extends Window

@export var open_file_handler : FileDialog
@export var editor_master : CanvasLayer
@export var error_popup : AcceptDialog
@export var error_popup_text : Label

@export_group("Boxel Image Controls")
@export var filepath_text : LineEdit
@export var boxelname_text : LineEdit
@export var preview_image : TextureRect
@export_group("Boxel Info Controls")
@export var boxel_type_selection : Array[CheckBox]
@export var boxel_layer_selection : Array[CheckBox]
@export var boxel_type_group : ButtonGroup
@export_group("Boxel Normal Controls")
@export var normals_tab_control : Control
@export var normal_image : TextureRect
@export var normalpath_text : LineEdit

var open_file_paths : Array[String] = []
var imported_src_image : Image
var imported_src_normal : Image
var imported_image_tex : ImageTexture
var imported_normal_tex : ImageTexture

var queue_import_time : int = 0

var selected_type : int = 0
var selected_layers : Array[int] = []

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
		$"../../..".EditToggle(false)
	

func FileImportCatch(files : Array[String], is_normal : bool) -> void:
	open_file_paths = files
	
	if is_normal:
		imported_src_normal = Image.load_from_file(files[0])
		
		if imported_src_image && imported_src_normal.get_size() != imported_src_image.get_size():
			ErrorPop("Imported Boxel Image and Normal image must have the same size.")
			imported_src_normal = null
			return
		
		UpdateNormalSettings()
	else:
		imported_src_image = Image.load_from_file(files[0])
		#if imported_src_normal && imported_src_image.get_size() != imported_src_normal.get_size():
			#ErrorPop("Imported Boxel Image and Normal image must have the same size.")
			#imported_src_image = null
			#return
		
		UpdateImageSettings()

func UpdateImageSettings():
	imported_image_tex = ImageTexture.create_from_image(imported_src_image)
	
	filepath_text.text = open_file_paths[0]
	preview_image.texture = imported_image_tex

func UpdateNormalSettings():
	imported_normal_tex = ImageTexture.create_from_image(imported_src_normal)
	
	normalpath_text.text = open_file_paths[0]
	normal_image.texture = imported_normal_tex

func ValidateImport():
	if boxel_type_group.get_pressed_button(): selected_type = boxel_type_group.get_pressed_button().get_meta("type_index")
	
	selected_layers = []
	for layer_button in boxel_layer_selection: if layer_button.button_pressed: selected_layers.append(layer_button.get_meta("layer_index")) 
	
	if selected_type == 0 && (imported_src_image.get_size() != Vector2i(32,32) || imported_src_normal.get_size() != Vector2i(32,32)):
		return "Images and Normals must be a 32x32 image when imported single boxels."
	if (selected_type == 1 || selected_type == 2) && (imported_src_image.get_size() != Vector2i(128,128) || imported_src_normal.get_size() != Vector2i(128,128)):
		return "Images and Normals must be a 32x32 image when imported single boxels."
	if !imported_src_image: return "Invalid or missing image."
	if selected_layers.size() == 0: return "Select 1 or more layers for the boxel type."
	
	return 0

func FinishImport():
	var validation_status = ValidateImport()
	if validation_status is String:
		ErrorPop(validation_status)
		return
	
	var selected_type = boxel_type_group.get_pressed_button().get_meta("type_index")
	
	var new_boxel : Boxel
	
	if selected_type == 0:
		var new_tile_info = TileInfo.new()
		new_boxel = UnitBoxel.new()
		new_tile_info.image = imported_image_tex
		new_boxel.tile_info = new_tile_info
		new_boxel.boxel_img = imported_image_tex
	elif selected_type == 1 || selected_type == 2:
		var new_tile_info_array : Array[TileInfo] = []
		var boxel_image_list = GenerateImages()
		for image in boxel_image_list: 
			var new_tile_info = TileInfo.new()
			new_tile_info.image = image
			new_tile_info_array.append(new_tile_info) 
		
		new_boxel = ConnectorBoxel.new()
		new_boxel.boxel_img = new_tile_info_array[0].image
		new_boxel.tile_array = new_tile_info_array
	
	new_boxel.layers = selected_layers
	new_boxel.boxel_name = StringName(boxelname_text.text)
	editor_master.library_grid.AddNewBoxel(new_boxel)
	
	var load_path = SceneLoadingContainer.SearchGenerateDirPath(SceneLoadingContainer.boxel_load_path + "/" + boxelname_text.text, "tres")
	
	var err = ResourceSaver.save(new_boxel, load_path)
	
	visible = false
	
	print(err)

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
