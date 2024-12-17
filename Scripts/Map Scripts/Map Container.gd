extends NavigationRegion2D

var free_nodes : Array[Node]

@export var layer_groups : Array[CanvasGroup]
@export var chunk_size : int

@export_group("Tile Resources")
@export var tile_prefab : PackedScene

@onready var generic_tile_object := load("res://Prefabs/World Objects/TileMap Tiles/non_collidable_tile.tscn")

var map_size : Vector2i
var bounds_offset : Vector2i = Vector2i.ZERO 
var chunk_origin : Vector2i = Vector2i.ZERO  # Defines the top left chunk's position as a relative origin point for the chunk array. Measured in chunks
var chunk_dimensions : Vector2i = Vector2i.ZERO

func _ready() -> void:
	layer_init(layer_groups[0])
	layer_init(layer_groups[1])
	layer_init(layer_groups[2])

func layer_init(layer_group : CanvasGroup) -> void:
	ResizeMapBounds()
	
	var chunk_temp : Array[Array] = []
	chunk_temp.resize(chunk_size)
	
	var column_temp : Array[Object] = []
	column_temp.resize(chunk_size)
	
	for x in chunk_size:
		chunk_temp[x] = column_temp.duplicate()
	
	var new_chunk_column : Array[Array] = []
	new_chunk_column.resize(chunk_dimensions.y)
	
	for y in chunk_dimensions.y:
		new_chunk_column[y] = chunk_temp.duplicate(true)
	
	layer_group.layer_array.resize(chunk_dimensions.x)
	
	for x in chunk_dimensions.x:
		layer_group.layer_array[x] = new_chunk_column.duplicate(true)
	
	
	for tile in layer_group.get_children():
		bind_array_tile(tile, layer_group)


func GetTile(tile_position : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_position.x > map_size.x - bounds_offset.x || tile_position.y > map_size.y - bounds_offset.y || tile_position.x < bounds_offset.x || tile_position.y < bounds_offset.y:
		return null
	
	var tile_array_index = tile_position % chunk_size
	var tile_chunk_index = ((tile_position - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
	return layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]

func GetTileByPixel(pixel_position : Vector2, layer_group : CanvasGroup) -> Node:
	var tile_position : Vector2i = floor((pixel_position + Vector2(16.0,16.0)) / 32)
	return GetTile(tile_position, layer_group)

func ResizeMapBounds() -> void:
	map_size = Vector2i.ZERO
	bounds_offset = Vector2i.ZERO
	
	var temp_map_pixel_size : Vector4 = Vector4(bounds_offset.x, bounds_offset.y, map_size.x, map_size.y) * 32
	for layer in get_children():
		for tile in layer.get_children():
			if tile.position.x > temp_map_pixel_size.z: temp_map_pixel_size.z = tile.position.x
			if tile.position.y > temp_map_pixel_size.w: temp_map_pixel_size.w = tile.position.y
			if tile.position.x < temp_map_pixel_size.x: temp_map_pixel_size.x = tile.position.x
			if tile.position.y < temp_map_pixel_size.y: temp_map_pixel_size.y = tile.position.y
	
	bounds_offset = round(Vector2(temp_map_pixel_size.x, temp_map_pixel_size.y)) / 32
	map_size = round(Vector2(temp_map_pixel_size.z, temp_map_pixel_size.w)) / 32
	map_size -= bounds_offset
	
	chunk_origin = floor(Vector2(bounds_offset) / chunk_size)
	chunk_dimensions = ceil(Vector2(map_size) / chunk_size)


func bind_array_tile(tile : Node, layer_group : CanvasGroup) -> void:
	var tile_position : Vector2i = round(tile.position / 32)
	var tile_array_index = tile_position % chunk_size
	var tile_chunk_index = ((tile_position - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
	layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = tile

func _physics_process(_delta) -> void:
	pass
	#query_free_nodes()

func query_free_nodes() -> void:
	var list_size = free_nodes.size()
	for n in list_size:
		var wr = weakref(free_nodes[list_size - n - 1])
		if !wr.get_ref():
			bake_navigation_polygon(false)
			free_nodes.remove_at(list_size - n - 1)

func PixelToTilePosition(pixel_pos : Vector2) -> Vector2i:
	return floor((pixel_pos + Vector2(16.0,16.0)) / 32)

func add_free_node(obj) -> void:
	free_nodes.append(obj)

func AddTile(tile_info : TileInfo, tile_pixel_pos : Vector2, layer : CanvasGroup) -> Node:
	var tile_pos = PixelToTilePosition(tile_pixel_pos)
	
	if tile_pos.x > map_size.x - bounds_offset.x || tile_pos.y > map_size.y - bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return null
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = ((tile_pos - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
	var prev_tile : Node = layer.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
	
	if prev_tile: prev_tile.queue_free()
	
	var new_tile = generic_tile_object.instantiate()
	new_tile.owner = self
	new_tile.texture = tile_info.image
	layer_groups[tile_info.layer].add_child(new_tile)
	new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
	
	layer.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = new_tile
	
	return new_tile


func ResetLayerVisibility() -> void:
	for layer in get_children():
		layer.material.set_shader_parameter("is_visible", true)

func DestroyTile(tile) -> void:
	tile.queue_free()
	add_free_node(tile)
	query_free_nodes()
