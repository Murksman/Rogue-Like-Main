@tool
extends Node2D
class_name MapGenerator

@export var tileMap : TileMap
@export var src_image : CompressedTexture2D
@export var partition_size : int
@export var Generate_Images : bool:
	get:
		return false
	set(arg): 
		GenerateImages()

@export var Generate_Map : bool:
	get: 
		return false
	set(arg):
		if tileMap != null:
			TestFunc()

@export var img_array : Array[Sprite2D]


func GenerateImages():
	for x in get_child_count():
		get_child(get_child_count() - x - 1).queue_free()
	
	img_array = []
	
	var img : Image = src_image.get_image()
	var imgSize : Vector2i = img.get_size()
	
	var partitions_col : int = floor(imgSize.y / partition_size)
	var partitions_row : int = floor(imgSize.x / partition_size)
	
	for y in partitions_col:
		for x in partitions_row:
			var curr_img_pos = Vector2i(x,y) * partition_size
			var new_img = img.get_region(Rect2i(curr_img_pos, Vector2i(partition_size, partition_size)))
			
			var new_sprite : Sprite2D = Sprite2D.new()
			new_sprite.texture = ImageTexture.create_from_image(new_img)
			$".".add_child(new_sprite)
			new_sprite.owner = get_tree().edited_scene_root
			new_sprite.position = Vector2(x,y) * partition_size
			new_sprite.name = "Sprite2D_" + str(x) + "_" + str(y)
			img_array.append(new_sprite)


func TestFunc():
	tileMap.get_used_cells(0)
	print("test")
