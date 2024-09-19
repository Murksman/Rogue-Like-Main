@tool
extends ActionableObject
class_name LevelExit


func _ready():
	if !Engine.is_editor_hint() || get_child_count() > 0: return
	
	var exit_image = TextureRect.new()
	var areaObj = CollisionShape2D.new()
	add_child(exit_image)
	add_child(areaObj)
	exit_image.owner = get_tree().edited_scene_root
	areaObj.owner = get_tree().edited_scene_root
	exit_image.name = "Exit Texture"
	areaObj.name + "Exit Shape"
	exit_image.texture = load("res://Sprites/Generic Objects/White_Texture.png")
	areaObj.shape = RectangleShape2D.new()
	areaObj.shape.size = exit_image.size
	

