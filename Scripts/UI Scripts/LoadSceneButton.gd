extends TextureButton

#@onready var file_save := $"../VBoxContainer"

func _pressed():
	get_tree().change_scene_to_file("res://Scenes/Maps/Main.tscn")
