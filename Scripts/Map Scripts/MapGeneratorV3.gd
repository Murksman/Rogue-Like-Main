@tool
extends Node2D
class_name MapGenerator

@export_group("Settings")
@export var Source_Image : CompressedTexture2D
@export var Source_Normal_Image : CompressedTexture2D
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
		BakeNavMesh()


@export_group("Tile Resources")
@export var image_array : Array[ImageTexture]
@export var normal_array : Array[ImageTexture]
@export var tileMap : TileMap
@export var vis_mask_container : Node2D
#@export var collidable_tile : Resource
#@export var non_collidable_tile : Resource
#@export var vis_mask_occluder : Resource

@onready var loaded_collidable : Object = preload("res://Prefabs/World Objects/TileMap Tiles/collidable_tile.tscn")
@onready var loaded_non_collidable : Object = preload("res://Prefabs/World Objects/TileMap Tiles/non_collidable_tile.tscn")
@onready var loaded_mask_occluder : Object = preload("res://Prefabs/World Objects/TileMap Tiles/light_mask_occluder.tscn")

var partitions_col : int
var partitions_row : int



func GenerateImages():
	image_array = []
	normal_array = []
	
	var img : Image = Source_Image.get_image()
	var normal_img : Image = Source_Normal_Image.get_image()
	var imgSize : Vector2i = img.get_size()
	
	if imgSize != img.get_size():
		printerr("The dimensions for the Source Image and Source Normal Image do not match.")
		return
	
	partitions_col = floor(imgSize.y / partition_size)
	partitions_row = floor(imgSize.x / partition_size)
	
	for y in partitions_col:
		for x in partitions_row:
			var curr_img_pos = Vector2i(x,y) * partition_size
			var new_img = img.get_region(Rect2i(curr_img_pos, Vector2i(partition_size, partition_size)))
			var new_normal_img = normal_img.get_region(Rect2i(curr_img_pos, Vector2i(partition_size, partition_size)))
			image_array.append(ImageTexture.create_from_image(new_img))
			normal_array.append(ImageTexture.create_from_image(new_normal_img))


func Clear():
	for x in get_child_count():
		get_child(get_child_count() - x - 1).queue_free()
	for x in vis_mask_container.get_child_count():
		vis_mask_container.get_child(vis_mask_container.get_child_count() - x - 1).queue_free()

func CompileMap():
	# Iterate through each layer in the tilemap
	for layer in tileMap.get_layers_count():
		var usedTiles = tileMap.get_used_cells(layer)
		# create a new tile for each tile in the tilemap
		for i in usedTiles:
			# gather data for the tile
			var tile_data : TileData = tileMap.get_cell_tile_data(layer,i)
			var target_image = ImageMap(tileMap.get_cell_atlas_coords(layer,i))
			var normal_image = NormalMap(tileMap.get_cell_atlas_coords(layer,i))
			var newTile : Node2D
			# create collision and occlusion if the wall is collidable
			if tile_data.get_custom_data("Collidable"):
				newTile = loaded_collidable.instantiate()
				var newMaskOccluder : LightOccluder2D = loaded_mask_occluder.instantiate()
				var polygon = tile_data.get_collision_polygon_points(0, 0)
				var wall_occluder = tile_data.get_occluder(1)
				var wall_tex_occluder = tile_data.get_occluder(0)
				
				newTile.get_child(0).get_child(0).polygon = polygon
				newTile.get_child(1).occluder = wall_occluder
				newTile.get_child(2).occluder = wall_tex_occluder
				newMaskOccluder.occluder.polygon = polygon
				
				newTile.name = "Collidable (" + str(i.x) + ", " + str(i.y) + ") Layer " + str(layer)
				newTile.breakable = tile_data.get_custom_data("Breakable")
				newTile.Health = tile_data.get_custom_data("Health")
				vis_mask_container.add_child(newMaskOccluder)
				newMaskOccluder.owner = newMaskOccluder.get_tree().edited_scene_root
				newMaskOccluder.global_position = Vector2(i * 32)
				newTile.occluder_child = newMaskOccluder
			# create simplified sprite for ground or other non-collidables
			else:
				newTile = loaded_non_collidable.instantiate()
				newTile.name = "Non-Collidable (" + str(i.x) + ", " + str(i.y) + ") Layer " + str(layer)
			# add the new tile into the scene
			add_child(newTile)
			set_editable_instance(newTile, true)
			newTile.texture = CanvasTexture.new()
			newTile.texture.diffuse_texture = target_image
			newTile.texture.normal_texture = normal_image
			newTile.owner = get_tree().edited_scene_root
			newTile.position = Vector2(i * 32)


func ImageMap(atlas_coords):
	var img_pos = (atlas_coords.y * partitions_row) + atlas_coords.x
	return image_array[img_pos]

func NormalMap(atlas_coords):
	var img_pos = (atlas_coords.y * partitions_row) + atlas_coords.x
	return normal_array[img_pos]

func DestroyTile(tile):
	tile.queue_free()
	$"..".add_free_node(tile)
	$"..".query_free_nodes()

func BakeNavMesh():
	$"..".bake_navigation_polygon(false)
