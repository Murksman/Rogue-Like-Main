extends Window

@export var open_file_handler : FileDialog
@export var filepath_text : LineEdit
@export var preview_image : TextureRect


var open_file_paths : Array[String] = []
var imported_src_image : Image
var imported_image_tex : ImageTexture

func WindowReady() -> void:
	RequestOpenFile()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Edit Mode"):
		$"../../..".EditToggle()

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
	print(imported_src_image)
	
	UpdateImportSettings()
