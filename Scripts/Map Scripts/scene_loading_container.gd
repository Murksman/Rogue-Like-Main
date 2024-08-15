extends Node
var load_file_path : String
var player_data : SaveData


# Called when the node enters the scene tree for the first time.
func _ready():
	if ResourceLoader.exists(load_file_path):
		player_data = ResourceLoader.load(load_file_path)
		print(player_data)

