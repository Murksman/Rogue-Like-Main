extends NavigationRegion2D

var free_nodes : Array[Node]

@export var layer_groups : Array[CanvasGroup]
@export var chunk_size : int
@export var chunk_background : Sprite2D
@export var level_save_root : Node2D

@export_group("Tile Resources")
@export var default_wall_occluders : PackedPolygonArray
@export var tile_object : PackedScene
@export var wall_object : PackedScene

var map_size : Vector2i
var bounds_offset : Vector2i = Vector2i.ZERO 
var chunk_origin : Vector2i = Vector2i.ZERO  # Defines the top left chunk's position as a relative origin point for the chunk array. Measured in chunks
var chunk_dimensions : Vector2i = Vector2i.ZERO

var chunk_temp : Array[Array] = []

var boxel_id_list : PackedInt32Array = []
var boxel_usage_list : PackedInt32Array = []
var loaded_object_list : Array[LvlObject] = []

var root_loaded = false

func _ready() -> void:
	SceneLoadingContainer.LoadResources()
	LoadResources()
	
	ResetMap()

func LoadResources(reset : bool = false):
	if root_loaded && !reset: return
	
	if reset: 
		loaded_object_list = []
	
	var boxel_paths = DirAccess.get_files_at(SceneLoadingContainer.lvlobject_load_path)
	
	for path in boxel_paths:
		if path.get_extension() == "depren": continue
		
		var load_path = SceneLoadingContainer.lvlobject_load_path + "/" + path
		var load_result = ResourceLoader.load(load_path)
		
		if load_result is LvlObject:
			loaded_object_list.append(load_result)
		else:
			print("Boxel Loading Error Code: ", load_result)
	
	root_loaded = true

func ResetMap():
	ResizeMapBounds()
	
	for layer in layer_groups:
		layer_init(layer)
	
	UpdateChunkBackground()

func layer_init(layer_group : CanvasGroup, ignore_existing = false) -> void:
	chunk_temp = []
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
	
	if ignore_existing: return
		
	for tile in layer_group.get_children():
		bind_array_tile(tile, layer_group)

func CheckSetMapSize(tile_pos : Vector2i) -> int:
	var chunk_coords : Vector2i = Vector2i(floor(Vector2(tile_pos) / chunk_size)) - chunk_origin
	
	if chunk_coords.x < 0:
		if chunk_coords.x + 1 < chunk_origin.x: return 1
		
		var new_chunk_column : Array[Array] = []
		new_chunk_column.resize(chunk_dimensions.y)
		
		for y in chunk_dimensions.y:
			new_chunk_column[y] = chunk_temp.duplicate(true)
		
		for layer in layer_groups:
			layer.layer_array.push_front(new_chunk_column.duplicate(true))
		
		chunk_dimensions.x += 1
		chunk_origin.x -= 1
	
	
	if chunk_coords.y < 0:
		if chunk_coords.y + 1 < chunk_origin.y: return 2
		for layer in layer_groups:
			for chunk_column in layer.layer_array:
				chunk_column.push_front(chunk_temp.duplicate(true))
		
		chunk_dimensions.y += 1
		chunk_origin.y -= 1
		
	
	if chunk_coords.x >= chunk_dimensions.x:
		if chunk_coords.x > chunk_dimensions.x: return 4
		
		var new_chunk_column : Array[Array] = []
		new_chunk_column.resize(chunk_dimensions.y)
		
		for y in chunk_dimensions.y:
			new_chunk_column[y] = chunk_temp.duplicate(true)
		
		for layer in layer_groups:
			layer.layer_array.append(new_chunk_column.duplicate(true))
		
		chunk_dimensions.x += 1
	
	if chunk_coords.y >= chunk_dimensions.y:
		if chunk_coords.y > chunk_dimensions.y: return 3
		for layer in layer_groups:
			for chunk_column in layer.layer_array:
				chunk_column.append(chunk_temp.duplicate(true))
		chunk_dimensions.y += 1
	
	map_size = chunk_dimensions * chunk_size
	bounds_offset = chunk_origin * chunk_size
	
	UpdateChunkBackground()
	return 0

func GetTile(tile_position : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_position.x >= map_size.x + bounds_offset.x || tile_position.y >= map_size.y + bounds_offset.y || tile_position.x < bounds_offset.x || tile_position.y < bounds_offset.y:
		return null
	
	var tile_array_index = tile_position % chunk_size
	var tile_chunk_index = Vector2i(floor(Vector2(tile_position) / chunk_size)) - chunk_origin
	
	return layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]

func ResizeMapBounds() -> void:
	map_size = Vector2i.ZERO
	bounds_offset = Vector2i.ZERO
	
	var temp_map_pixel_size : Vector2 = Vector2.ZERO
	var temp_map_pixel_offset : Vector2 = Vector2.ZERO
	for layer in layer_groups:
		for tile in layer.get_children():
			if tile.position.x > temp_map_pixel_size.x: temp_map_pixel_size.x = tile.position.x
			if tile.position.y > temp_map_pixel_size.y: temp_map_pixel_size.y = tile.position.y
			if tile.position.x < temp_map_pixel_offset.x: temp_map_pixel_offset.x = tile.position.x
			if tile.position.y < temp_map_pixel_offset.y: temp_map_pixel_offset.y = tile.position.y
	
	var tile_offset = PixelToTilePosition(temp_map_pixel_offset)
	var tile_size = PixelToTilePosition(temp_map_pixel_size)
	
	chunk_origin = Vector2i(floor(Vector2(tile_offset) / chunk_size))
	chunk_dimensions = Vector2i(floor(Vector2(tile_size) / chunk_size)) - chunk_origin + Vector2i(1,1)
	
	map_size = chunk_dimensions * chunk_size
	bounds_offset = chunk_origin * chunk_size
	
	UpdateChunkBackground()


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
	return floor(pixel_pos / 32)

func add_free_node(obj) -> void:
	free_nodes.append(obj)

func CalcAdjacency(tile_pos : Vector2i, layer_group : CanvasGroup) -> int:
	var adjacency_index = 0
	
	if GetTile(tile_pos - Vector2i(1,0), layer_group): adjacency_index |= 1
	if GetTile(tile_pos - Vector2i(-1,0), layer_group): adjacency_index |= 2
	if GetTile(tile_pos - Vector2i(0,1), layer_group): adjacency_index |= 4
	if GetTile(tile_pos - Vector2i(0,-1), layer_group): adjacency_index |= 8
	
	return adjacency_index

func CreateTile(tile_pos : Vector2i, layer_group : CanvasGroup, boxel : LvlObject = null, adjacency : int = -1) -> Node2D:
	if tile_pos.x >= map_size.x + bounds_offset.x || tile_pos.y >= map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return null
	
	if !boxel: 
		var tmp_tile = GetTile(tile_pos, layer_group)
		if !tmp_tile: return
		var boxel_index = loaded_object_list.find_custom(func(b): return b.boxel_id == tmp_tile.boxel_id)
		boxel = loaded_object_list[boxel_index]
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(floor(Vector2(tile_pos) / chunk_size)) - chunk_origin
	var prev_tile : Node2D = layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
	
	var boxel_match_index = boxel_id_list.bsearch(boxel.boxel_id)
	if boxel_id_list.size() == 0 || boxel_match_index + 1 > boxel_id_list.size():
		boxel_id_list.append(boxel.boxel_id)
		boxel_usage_list.append(1)
		print("New LvlObject Added to ID List: - ", boxel.boxel_id)
	elif boxel_id_list[boxel_match_index] != boxel.boxel_id:
		boxel_id_list.insert(boxel_match_index, boxel.boxel_id)
		boxel_usage_list.insert(boxel_match_index, 1)
		print("New LvlObject Added to ID List: - ", boxel.boxel_id)
	else:
		boxel_usage_list[boxel_match_index] += 1
	
	if prev_tile:
		var prev_match_index = boxel_id_list.find(prev_tile.boxel_id)
		
		if prev_match_index == -1:
			printerr("Error: Prev Tile at Position: ", boxel.boxel_id, " - ",prev_tile.position, " - LvlObject ID did not match any in the list.")
		else:
			if boxel_usage_list[prev_match_index] <= 1:
				boxel_id_list.remove_at(prev_match_index)
				boxel_usage_list.remove_at(prev_match_index)
			else:
				boxel_usage_list[prev_match_index] -= 1
		
		prev_tile.queue_free()
	
	var tile_info : TileInfo
	var new_tile : Node2D
	
	if boxel is ConnectorBoxel: 
		if adjacency == -1:
			adjacency = CalcAdjacency(tile_pos, layer_group)
		
		tile_info = boxel.GetConnectedTile(adjacency)
		new_tile = wall_object.instantiate()
		set_editable_instance(new_tile, true)
		new_tile.get_child(2).occluder = default_wall_occluders.polygon_data[LevelInfo.connector_boxel_matrix[adjacency]]
	else: 
		tile_info = boxel.GetTileInfo()
		new_tile = tile_object.instantiate()
		set_editable_instance(new_tile, true)
	
	new_tile.boxel_id = boxel.boxel_id
	new_tile.texture = tile_info.image
	layer_group.add_child(new_tile)
	new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
	
	layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = new_tile
	
	return new_tile

func AddTile(boxel : LvlObject, tile_pos : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_pos.x > map_size.x + bounds_offset.x || tile_pos.y > map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return null
	
	var tile_info : TileInfo
	var new_tile : Node
	if boxel is UnitBoxel || boxel is ScatterBoxel:
		new_tile = CreateTile(tile_pos, layer_group, boxel)
	elif boxel is ConnectorBoxel:
		var adjacent_index = CalcAdjacency(tile_pos, layer_group)
		tile_info = boxel.GetConnectedTile(adjacent_index)
		new_tile = CreateTile(tile_pos, layer_group, boxel, adjacent_index)
		
		if adjacent_index & 1: CreateTile(tile_pos - Vector2i(1,0), layer_group, boxel)
		if adjacent_index & 2: CreateTile(tile_pos - Vector2i(-1,0), layer_group, boxel)
		if adjacent_index & 4: CreateTile(tile_pos - Vector2i(0,1), layer_group, boxel)
		if adjacent_index & 8: CreateTile(tile_pos - Vector2i(0,-1), layer_group, boxel)
	else: return null
	
	return new_tile

func GetPackedTileArray(layer : CanvasGroup, map_array_length : int) -> PackedByteArray:
	var packed_array : PackedByteArray = []
	
	packed_array.resize(map_array_length)
	
	var n = 0
	for chunk_col in layer.layer_array:
		for chunk in chunk_col:
			for col in chunk:
				for tile in col:
					if tile:
						packed_array[n] = boxel_id_list.find(tile.boxel_id) + 1
					else: 
						packed_array[n] = 0
					n += 1
	
	return packed_array

func ReadPackedTileArray(layer : CanvasGroup, arr : PackedByteArray, temp_boxel_load_list : Array[LvlObject]) -> String:
	var n = 0
	for a in layer.layer_array.size():
		var chunk_col = layer.layer_array[a]
		for b in chunk_col.size():
			var chunk = chunk_col[b]
			for c in chunk.size():
				var col = chunk[c]
				for d in col.size():
					var tile = col[d]
					if arr[n] != 0:
						if arr[n] > temp_boxel_load_list.size(): return 'map tile index is out of bounds - ' + str(arr[n])
						
						var tile_pos = Vector2i(a, b) * chunk_size + Vector2i(c, d)
						AddTile(temp_boxel_load_list[arr[n]-1], tile_pos, layer)
					n += 1
	
	return ""

func UpdateChunkBackground() -> void:
	var temp_size = chunk_dimensions * chunk_size * 32
	chunk_background.texture.width = max(temp_size.x, 8)
	chunk_background.texture.height = max(temp_size.y, 8)
	chunk_background.position = (chunk_origin * chunk_size * 32) + (temp_size / 2)

func ResetLayerVisibility() -> void:
	for layer in layer_groups:
		layer.material.set_shader_parameter("is_visible", true)

func EraseAtPosition(tile_pos : Vector2i, layer_group : CanvasGroup, update_adjacent : bool = true) -> void:
	var tile = GetTile(tile_pos, layer_group)
	
	if !tile: return 
	
	DestroyTile(tile)
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(floor(Vector2(tile_pos) / chunk_size)) - chunk_origin
	layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = null
	
	if update_adjacent:
		var adjacent_index = CalcAdjacency(tile_pos, layer_group)
		
		if adjacent_index & 1: CreateTile(tile_pos - Vector2i(1,0), layer_group)
		if adjacent_index & 2: CreateTile(tile_pos - Vector2i(-1,0), layer_group)
		if adjacent_index & 4: CreateTile(tile_pos - Vector2i(0,1), layer_group)
		if adjacent_index & 8: CreateTile(tile_pos - Vector2i(0,-1), layer_group)

func ShapeTool(box_dimensions : Rect2i, layer_group : CanvasGroup, boxel : LvlObject, hollow : bool = false, update_adjacent : bool = true) -> void:
	box_dimensions.position.x = maxi(box_dimensions.position.x, bounds_offset.x)
	box_dimensions.position.y = maxi(box_dimensions.position.y, bounds_offset.y)
	box_dimensions.size.x = mini(box_dimensions.size.x, map_size.x + bounds_offset.x)
	box_dimensions.size.y = mini(box_dimensions.size.y, map_size.y + bounds_offset.y)
	
	if !hollow && box_dimensions.size.x > 2 && box_dimensions.size.y > 2:
		for x in box_dimensions.size.x - 2:
			for y in box_dimensions.size.y - 2:
				CreateTile(box_dimensions.position + Vector2i(x+1,y+1), layer_group, boxel, 15)
	
	for x in box_dimensions.size.x:
		CreateTile(box_dimensions.position + Vector2i(x,0), layer_group, boxel, 0)
		CreateTile(box_dimensions.position + Vector2i(x,box_dimensions.size.y-1), layer_group, boxel, 0)
	
	for y in box_dimensions.size.y - 2:
		CreateTile(box_dimensions.position + Vector2i(0,y+1), layer_group, boxel, 0)
		CreateTile(box_dimensions.position + Vector2i(box_dimensions.size.x-1,y+1), layer_group, boxel, 0)
	
	for x in box_dimensions.size.x + 2:
		for y in box_dimensions.size.y + 2:
			CreateTile(box_dimensions.position + Vector2i(x-1,y-1), layer_group)

func EraserShapeTool(box_dimensions : Rect2i, layer_group : CanvasGroup, hollow : bool = false, update_adjacent : bool = true):
	box_dimensions.position.x = maxi(box_dimensions.position.x, bounds_offset.x)
	box_dimensions.position.y = maxi(box_dimensions.position.y, bounds_offset.y)
	box_dimensions.size.x = mini(box_dimensions.size.x, map_size.x + bounds_offset.x)
	box_dimensions.size.y = mini(box_dimensions.size.y, map_size.y + bounds_offset.y)
	
	for x in box_dimensions.size.x:
		for y in box_dimensions.size.y:
			EraseAtPosition(box_dimensions.position + Vector2i(x,y), layer_group, false)
		
		CreateTile(box_dimensions.position + Vector2i(x, -1), layer_group)
		CreateTile(box_dimensions.position + Vector2i(x, box_dimensions.size.y), layer_group)
	
	for y in box_dimensions.size.y:
		CreateTile(box_dimensions.position + Vector2i(-1, y), layer_group)
		CreateTile(box_dimensions.position + Vector2i(box_dimensions.size.x, y), layer_group)

func DestroyTile(tile : Node2D) -> void:
	tile.queue_free()
	add_free_node(tile)
	query_free_nodes()

func WipeMapTiles(new_chunk_size : Vector2i = Vector2i(0,0)) -> void:
	chunk_dimensions = new_chunk_size
	for layer in layer_groups:
		for child in layer.get_children():
			child.queue_free()
		
		layer_init(layer, true)

func SortBoxels():
	loaded_object_list.sort_custom(func(b1, b2): return b1.boxel_id > b2.boxel_id)

func AssignTileOwner() -> void:
	for layer in layer_groups:
		layer.owner = level_save_root
		for child in layer.get_children():
			child.owner = level_save_root

func AddEntity(lvl_obj : LvlObject, pos : Vector2, args : Dictionary = {}) -> Node:
	print("Adding Entity - ", lvl_obj)
	var index : int = SceneLoadingContainer.loaded_entities.bsearch_custom(lvl_obj.obj_type, func(a, b): return a.id < b.id)
	var entity = SceneLoadingContainer.loaded_entities[index].instantiate()
	
	if args.size() == 0: args = lvl_obj.property_list
	
	entity.MapArgs(args)
	
	if lvl_obj is EntityObject: layer_groups[3].add_child(entity)
	elif lvl_obj is LightObject: layer_groups[4].add_child(entity)
	else: print("Error Adding Entity - Invalid Type: ", lvl_obj.name)
	
	entity.position = pos
	
	return entity

func DeleteEntity(entity : Entity) -> void:
	entity.queue_free()

func GetNearestObjects(object_layer : CanvasGroup, t_point : Vector2, max_distance : float, exclusive : bool = false) -> Array:
	if exclusive:
		var closest = null
		var dist := max_distance
		for obj in object_layer.get_children():
			var t_dist = obj.global_position.distance_to(t_point)
			if t_dist < dist:
				dist = t_dist
				closest = obj
		return [closest]
	
	var obj_list = []
	
	for obj in object_layer.get_children():
		if obj.global_position.distance_to(t_point) < max_distance:
			obj_list.append(obj)
	
	return obj_list
