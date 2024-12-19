extends Window

@export var open_file_handler : FileDialog
@export var filepath_text : LineEdit
@export var boxelname_text : LineEdit
@export var preview_image : TextureRect
@export var editor_master : CanvasLayer

var open_file_paths : Array[String] = []
var imported_src_image : Image
var imported_image_tex : ImageTexture

var queue_import_time : int = 0

func _process(delta: float) -> void:
	if queue_import_time > 0:
		queue_import_time -= 1
		if queue_import_time == 0: RequestOpenFile()

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

func RequestOpenFile() -> void:
	open_file_handler.file_open_return = self
	open_file_handler.popup()
	

func UpdateImportSettings():
	imported_image_tex = ImageTexture.create_from_image(imported_src_image)
	
	filepath_text.text = open_file_paths[0]
	preview_image.texture = imported_image_tex

func FileImportCatch(files : Array[String]) -> void:
	open_file_paths = files
	
	imported_src_image = Image.load_from_file(open_file_paths[0])
	
	UpdateImportSettings()

func _on_button_pressed() -> void:
	RequestOpenFile()

func FinishImport():
	var new_boxel = UnitBoxel.new()
	var new_tile_info = TileInfo.new()
	new_tile_info.image = imported_image_tex
	var layers : Array[int] = [editor_master.selected_layer]
	new_tile_info.layers = layers
	new_tile_info.tile_name = boxelname_text.text
	new_boxel.tile_info = new_tile_info
	new_boxel.boxel_img = imported_image_tex
	new_boxel.boxel_name = boxelname_text.text
	editor_master.library_grid.AddNewBoxel(new_boxel)
 
func _on_finish_import_button_pressed() -> void:
	FinishImport()
	visible = false
