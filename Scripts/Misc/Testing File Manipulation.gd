extends Node

@export var boxel_temp_list : Array[Boxel]

var file : FileAccess
var cursor : int = 0

var boxel_ids : PackedInt32Array = []

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	CalcBoxelIDS()
	
	OpenFile()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Use Action"):
		TestReadFile()

func CalcBoxelIDS(boxel_list : Array[Boxel] = boxel_temp_list, wipe_existing : bool = false):
	boxel_ids.resize(boxel_list.size())
	
	for i in boxel_list.size():
		boxel_ids[i] = rng.randi()

func OpenFile():
	file = FileAccess.open("user://TestingFile.txt",FileAccess.WRITE_READ)

func TestReadFile():
	rng.randomize()
	
	#file.resize(1)
	
	WriteFileFormat()

func WriteFileFormat():
	var tile_buff : PackedByteArray = boxel_ids.to_byte_array()
	
	file.seek(0)
	
	file.store_string("hello / world\n")
	file.store_string("Int Bytes: ")
	file.store_32(rng.randi())
	file.store_string("\nLevel Data Layer: ")
	file.store_buffer(tile_buff)
	
	
	#var buff : PackedByteArray = []
	#buff.append_array(("Int Bytes: " + str(rng.randi()) + "\n").to_utf8_buffer()) 
	


	print()
