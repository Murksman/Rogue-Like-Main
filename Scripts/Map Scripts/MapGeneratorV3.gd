@tool
extends Node2D
class_name MapGenerator

@export_group("Settings")
@export var Source_Image : CompressedTexture2D
@export var tileMap : TileMap
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
			CompileMap()

@export var Clear_Tiles : bool:
	get: 
		return false
	set(arg):
		Clear()

@export var Bake_Nav_Mesh : bool:
	get: 
		return false
	set(arg):
		$"..".bake_navigation_polygon(true)


@export_group("Tile Resources")
@export var image_array : Array[ImageTexture]

@export var collidable_tile : Resource
@export var non_collidable_tile : Resource

var loaded_collidable : Object
var loaded_non_collidable : Object

var partitions_col : int
var partitions_row : int

func GenerateImages():
	image_array = []
	
	var img : Image = Source_Image.get_image()
	var imgSize : Vector2i = img.get_size()
	
	partitions_col = floor(imgSize.y / partition_size)
	partitions_row = floor(imgSize.x / partition_size)
	
	for y in partitions_col:
		for x in partitions_row:
			var curr_img_pos = Vector2i(x,y) * partition_size
			var new_img = img.get_region(Rect2i(curr_img_pos, Vector2i(partition_size, partition_size)))
			image_array.append(ImageTexture.create_from_image(new_img))


func Clear():
	for x in get_child_count():
		get_child(get_child_count() - x - 1).queue_free()

func CompileMap():
	loaded_collidable = load(str(collidable_tile.resource_path))
	loaded_non_collidable = load(str(non_collidable_tile.resource_path))
	for layer in tileMap.get_layers_count():
		var usedTiles = tileMap.get_used_cells(layer)
		for i in usedTiles:
			var tile_data = tileMap.get_cell_tile_data(layer,i)
			var target_image = ImageMap(tileMap.get_cell_atlas_coords(layer,i))
			var newTile
			if tile_data.get_custom_data("Collidable"):
				newTile = loaded_collidable.instantiate()
				var polygon = tile_data.get_collision_polygon_points(0, 0)
				newTile.get_child(0).get_child(0).polygon = polygon
				newTile.get_child(1).occluder.polygon = polygon
				newTile.texture = target_image
				newTile.name = "Collidable (" + str(i.x) + ", " + str(i.y) + ") Layer: " + str(layer)
			else:
				newTile = loaded_non_collidable.instantiate()
				newTile.texture = target_image
				newTile.name = "Non-Collidable (" + str(i.x) + ", " + str(i.y) + ") Layer: " + str(layer)
			add_child(newTile)
			newTile.owner = get_tree().edited_scene_root
			newTile.position = Vector2(i * 32)


func ImageMap(atlas_coords):
	var img_pos = (atlas_coords.y * partitions_row) + atlas_coords.x
	return image_array[img_pos]
