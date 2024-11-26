extends NavigationRegion2D

var free_nodes : Array[Node]

@export var generate_map_array : bool:
	set(arg):
		layer_init(floor_group)
		generate_map_array = false

@export var target_tile_position : Vector2i

@export var set_tile_visibility : bool:
	set(arg):
		var tile = GetTile(target_tile_position, floor_group)
		if tile: tile.visible = !tile.visible
		else: printerr("No Tile Found at: ", target_tile_position)
		set_tile_visibility = false

@export var floor_group : CanvasGroup
@export var wall_group : CanvasGroup
@export var entity_group : CanvasGroup
@export var chunk_size : int

var map_size : Vector2i
var bounds_offset : Vector2i = Vector2i.ZERO 
var chunk_origin : Vector2i = Vector2i.ZERO  # Defines the top left chunk's position as a relative origin point for the chunk array. Measured in chunks
var chunk_dimensions : Vector2i = Vector2i.ZERO

func _ready():
	layer_init(floor_group)
	layer_init(wall_group)
	layer_init(entity_group)

func layer_init(layer_group : CanvasGroup):
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

func ResizeMapBounds():
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

func bind_array_tile(tile : Node, layer_group : CanvasGroup):
	var tile_position : Vector2i = round(tile.position / 32)
	var tile_array_index = tile_position % chunk_size
	var tile_chunk_index = ((tile_position - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
	layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = tile

func _physics_process(_delta):
	pass
	#query_free_nodes()

func query_free_nodes():
	var list_size = free_nodes.size()
	for n in list_size:
		var wr = weakref(free_nodes[list_size - n - 1])
		if (!wr.get_ref()):
			bake_navigation_polygon(false)
			free_nodes.remove_at(list_size - n - 1)

func add_free_node(obj):
	free_nodes.append(obj)

func DestroyTile(tile):
	tile.queue_free()
	add_free_node(tile)
	query_free_nodes()
