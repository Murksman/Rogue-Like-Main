extends TextureButton

@export var file_index : int

func _pressed():
	$"../../../../..".SaveFile(file_index)
