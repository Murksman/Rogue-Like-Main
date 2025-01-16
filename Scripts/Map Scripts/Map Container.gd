extends NavigationRegion2D

var free_nodes : Array[Node]

@export var layer_groups : Array[CanvasGroup]
@export var chunk_size : int
@export var chunk_background : Sprite2D

@export_group("Tile Resources")
@export var tile_prefab : PackedScene

@onready var generic_tile_object := load("res://Prefabs/World Objects/TileMap Tiles/non_collidable_tile.tscn")

var map_size : Vector2i
var bounds_offset : Vector2i = Vector2i.ZERO 
var chunk_origin : Vector2i = Vector2i.ZERO  # Defines the top left chunk's position as a relative origin point for the chunk array. Measured in chunks
var chunk_dimensions : Vector2i = Vector2i.ZERO

var chunk_temp : Array[Array] = []
var new_chunk_column : Array[Array] = []

func _ready() -> void:
	layer_init(layer_groups[0])
	layer_init(layer_groups[1])
	layer_init(layer_groups[2])
	UpdateChunkBackground()

func layer_init(layer_group : CanvasGroup) -> void:
	ResizeMapBounds()
	
	chunk_temp = []
	chunk_temp.resize(chunk_size)
	
	var column_temp : Array[Object] = []
	column_temp.resize(chunk_size)
	
	for x in chunk_size:
		chunk_temp[x] = column_temp.duplicate()
	
	new_chunk_column = []
	new_chunk_column.resize(chunk_dimensions.y)
	
	for y in chunk_dimensions.y:
		new_chunk_column[y] = chunk_temp.duplicate(true)
	
	layer_group.layer_array.resize(chunk_dimensions.x)
	
	for x in chunk_dimensions.x:
		layer_group.layer_array[x] = new_chunk_column.duplicate(true)
	
	
	for tile in layer_group.get_children():
		bind_array_tile(tile, layer_group)

func CheckSetMapSize(tile_pos : Vector2i) -> int:
	var chunk_coords : Vector2i = (tile_pos / chunk_size) - chunk_origin
	
	#print("Tile pos: ", tile_pos, " Chunk Coords: ", chunk_coords)
	
	if chunk_coords.x < 0:
		#print("test x negative")
		if chunk_coords.x + 1 < chunk_origin.x: return 1
		for layer in layer_groups:
			layer.layer_array.push_front(new_chunk_column.duplicate(true))
		chunk_origin.x = chunk_coords.x
		chunk_dimensions.x = (tile_pos.x / chunk_size) - chunk_origin.x
	
	if chunk_coords.y < 0:
		#print("test y negative")
		if chunk_coords.y + 1 < chunk_origin.y: return 1
		for layer in layer_groups:
			for chunk_column in layer.layer_array:
				chunk_column.push_front(chunk_temp.duplicate(true))
		chunk_origin.y = chunk_coords.y
		chunk_dimensions.y = (tile_pos.y / chunk_size) - chunk_origin.y
	
	if chunk_coords.x >= chunk_dimensions.x:
		#print("test x positive")
		if chunk_coords.x > chunk_dimensions.x: return 4
		for layer in layer_groups:
			layer.layer_array.append(new_chunk_column.duplicate(true))
		chunk_dimensions.x = chunk_coords.x + 1
	
	if chunk_coords.y >= chunk_dimensions.y:
		#print("test y positive")
		if chunk_coords.y > chunk_dimensions.y: return 3
		for layer in layer_groups:
			for chunk_column in layer.layer_array:
				chunk_column.append(chunk_temp.duplicate(true))
		chunk_dimensions.y = chunk_coords.y + 1
	
	map_size = chunk_dimensions * chunk_size * 32
	bounds_offset = chunk_origin * chunk_size * 32
	
	UpdateChunkBackground()
	return 0

func GetTile(tile_position : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_position.x > map_size.x - bounds_offset.x || tile_position.y > map_size.y - bounds_offset.y || tile_position.x < bounds_offset.x || tile_position.y < bounds_offset.y:
		print("o.o.b", tile_position)
		return null
	
	var tile_array_index = tile_position % chunk_size
	var tile_chunk_index = ((tile_position - tile_array_index) / chunk_size) - chunk_origin
	return layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]

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

func CalcAdjacency(boxel : Boxel, tile_pos : Vector2i, layer_group : CanvasGroup, return_only = true) -> TileInfo:
	#print(tile_pos)
	var adjacency_index = 0
	var test_left = GetTile(tile_pos - Vector2i(1,0), layer_group)
	var test_right = GetTile(tile_pos - Vector2i(-1,0), layer_group)
	var test_up = GetTile(tile_pos - Vector2i(0,1), layer_group)
	var test_down = GetTile(tile_pos - Vector2i(0,-1), layer_group)
	print(test_left, test_right, test_up, test_down)
	if test_left: adjacency_index += 1
	if test_right: adjacency_index += 2
	if test_up: adjacency_index += 4
	if test_down: adjacency_index += 8
	
	print("adjacency - ", adjacency_index)
	
	if !return_only:
		if test_left: CreateTile(boxel, tile_pos - Vector2i(1,0), layer_group)
		if test_right: CreateTile(boxel, tile_pos - Vector2i(-1,0), layer_group)
		if test_up: CreateTile(boxel, tile_pos - Vector2i(0,1), layer_group)
		if test_down: CreateTile(boxel, tile_pos - Vector2i(0,-1), layer_group)
	
	return boxel.GetConnectedTile(adjacency_index)

func CreateTile(boxel : Boxel, tile_pos : Vector2i, layer_group : CanvasGroup, tile_info : TileInfo = null):
	print("Create Tile - ", tile_pos)
	if !tile_info: tile_info = CalcAdjacency(boxel, tile_pos, layer_group)
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = ((tile_pos - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
	var prev_tile : Node = layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
	
	if prev_tile: prev_tile.queue_free()
	
	var new_tile = generic_tile_object.instantiate()
	new_tile.texture = tile_info.image
	layer_group.add_child(new_tile)
	new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
	
	layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = new_tile
	
	#print(layer_group.get_child_count())
	
	return new_tile

func AddTile(boxel : Boxel, tile_pos : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_pos.x > map_size.x - bounds_offset.x || tile_pos.y > map_size.y - bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return null
	
	var tile_info
	if boxel is UnitBoxel || boxel is ScatterBoxel:
		tile_info = boxel.GetTileInfo()
	elif boxel is ConnectorBoxel:
		tile_info = CalcAdjacency(boxel, tile_pos, layer_group, false)
	else: return null
	
	var new_tile = CreateTile(boxel, tile_pos, layer_group, tile_info)
	
	return new_tile

func UpdateChunkBackground() -> void:
	var temp_size = chunk_dimensions * chunk_size * 32
	chunk_background.texture.width = max(temp_size.x, 8)
	chunk_background.texture.height = max(temp_size.y, 8)
	chunk_background.position = (chunk_origin * chunk_size * 32) + (temp_size / 2)

func ResetLayerVisibility() -> void:
	for layer in get_children():
		layer.material.set_shader_parameter("is_visible", true)

func DestroyTile(tile) -> void:
	tile.queue_free()
	add_free_node(tile)
	query_free_nodes()
