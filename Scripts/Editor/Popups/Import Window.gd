extends Window

@export var open_file_handler : FileDialog
@export var editor_master : CanvasLayer

@export_group("Boxel Image Controls")
@export var filepath_text : LineEdit
@export var boxelname_text : LineEdit
@export var preview_image : TextureRect
@export_group("Boxel Info Controls")
@export var boxel_type_selection : Array[CheckBox]
@export var boxel_layer_selection : Array[CheckBox]
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

func _process(delta: float) -> void:
	if queue_import_time > 0:
		queue_import_time -= 1
		if queue_import_time == 0: open_file_handler.RequestOpenFile(self)

func WindowReady() -> void:
	if !preview_image.texture: queue_import_time = 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		$"../../..".EditToggle(false)

func UpdateImageSettings():
	imported_image_tex = ImageTexture.create_from_image(imported_src_image)
	
	filepath_text.text = open_file_paths[0]
	preview_image.texture = imported_image_tex

func UpdateNormalSettings():
	imported_normal_tex = ImageTexture.create_from_image(imported_src_image)

func ImageImportCatch(files : Array[String]) -> void:
	imported_src_image = Image.load_from_file(files[0])
	
	UpdateImageSettings()

func NormalImportCatch(files : Array[String]) -> void:
	imported_src_normal = Image.load_from_file(files[0])
	
	UpdateNormalSettings()

func ValidateImport():
	if !imported_src_image: return "Invalid or missing image."
	if !editor_master.layer_button_group.get_pressed_button(): return "Select 1 or more layers for the boxel type."
	return 0

func FinishImport():
	var validation_status = ValidateImport()
	if validation_status is String:
		printerr(validation_status)
		return
	
	var new_boxel = UnitBoxel.new()
	var new_tile_info = TileInfo.new()
	new_tile_info.image = imported_image_tex
	var layers : Array[int] = [editor_master.layer_button_group.get_pressed_button().layer_int]
	new_tile_info.tile_name = boxelname_text.text
	new_boxel.tile_info = new_tile_info
	new_boxel.layers = layers
	new_boxel.boxel_img = imported_image_tex
	new_boxel.boxel_name = boxelname_text.text
	editor_master.library_grid.AddNewBoxel(new_boxel)
	
	var load_path = SceneLoadingContainer.SearchGenerateDirPath(SceneLoadingContainer.boxel_load_path + "/" + boxelname_text.text, "tres")
	
	var err = ResourceSaver.save(new_boxel, load_path)
	
	visible = false
	print(err)

func _on_finish_import_button_pressed() -> void:
	FinishImport()

func _on_files_dropped(files: PackedStringArray) -> void:
	if normals_tab_control.get_global_rect().has_point(get_mouse_position()):
		NormalImportCatch(files)
	else:
		ImageImportCatch(files)

func _on_file_path_button_pressed() -> void:
	open_file_handler.RequestOpen(self)
