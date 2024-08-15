extends TextureButton

@export var file_index : int

func _pressed():
	$"../../../../..".LoadFile(file_index).test_data
	print("data: " + $"../../../../..".LoadFile(file_index).test_data)
