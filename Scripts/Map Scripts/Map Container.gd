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
@export var enemy_mask_object : PackedScene
@export var vision_occluder : PackedScene

var map_size : Vector2i
var bounds_offset : Vector2i = Vector2i.ZERO 
var chunk_origin : Vector2i = Vector2i.ZERO  # Defines the top left chunk's position as a relative origin point for the chunk array. Measured in chunks
var chunk_dimensions : Vector2i = Vector2i.ZERO

var chunk_temp : Array[Array] = []

var boxel_id_list : PackedInt32Array = []
var boxel_usage_list : PackedInt32Array = []
var loaded_object_list : Array[LvlObject] = []
var entity_id_list : PackedInt32Array = []
var entity_usage_list : PackedInt32Array = []

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
			printerr("Boxel Loading Error Code: ", load_result)
	
	loaded_object_list.sort_custom(func(a,b): return a.id < b.id)
	
	root_loaded = true

func ResetMap():
	ResizeMapBounds()
	
	for i in 6:
		layer_init(layer_groups[i])
	
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

func CheckMapSize(tile_pos : Vector2i) -> bool:
	return !(tile_pos.x >= map_size.x + bounds_offset.x || tile_pos.y >= map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y)

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

func GetTile(tile_pos : Vector2i, layer_group : CanvasGroup) -> Node:
	if tile_pos.x >= map_size.x + bounds_offset.x || tile_pos.y >= map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return null
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(floor(Vector2(tile_pos) / chunk_size)) - chunk_origin
	
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
	var tile_pos : Vector2i = round(tile.position / 32)
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = ((tile_pos - tile_array_index) / chunk_size) - Vector2i(1,1) - chunk_origin
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
		var boxel_index = loaded_object_list.find_custom(func(b): return b.id == tmp_tile.id)
		boxel = loaded_object_list[boxel_index]
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(floor(Vector2(tile_pos) / chunk_size)) - chunk_origin
	var prev_tile : Node2D = layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
	
	var boxel_match_index = boxel_id_list.bsearch(boxel.id)
	if boxel_id_list.size() == 0 || boxel_match_index + 1 > boxel_id_list.size():
		boxel_id_list.append(boxel.id)
		boxel_usage_list.append(1)
		print("New LvlObject Added to ID List: - ", boxel.id)
	elif boxel_id_list[boxel_match_index] != boxel.id:
		boxel_id_list.insert(boxel_match_index, boxel.id)
		boxel_usage_list.insert(boxel_match_index, 1)
		print("New LvlObject Added to ID List: - ", boxel.id)
	else:
		boxel_usage_list[boxel_match_index] += 1
	
	if prev_tile:
		var prev_match_index = boxel_id_list.find(prev_tile.id)
		
		if prev_match_index == -1:
			printerr("Error: Prev Tile at Position: ", boxel.id, " - ",prev_tile.position, " - LvlObject ID did not match any in the list.")
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
		var new_occluder = vision_occluder.instantiate()
		set_editable_instance(new_tile, true)
		var polygon := default_wall_occluders.polygon_data[LevelInfo.connector_boxel_matrix[adjacency]]
		new_tile.get_child(2).occluder = polygon
		new_occluder.occluder = polygon
		SceneLoadingContainer.occluder_container.add_child(new_occluder)
		
		layer_group.add_child(new_tile)
		new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
		new_occluder.global_position = new_tile.global_position
	else: 
		tile_info = boxel.GetTileInfo()
		new_tile = tile_object.instantiate()
		set_editable_instance(new_tile, true)
		layer_group.add_child(new_tile)
		new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
	
	new_tile.id = boxel.id
	new_tile.texture = tile_info.image
	
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

func AddEnemyMaskTile(tile_pos : Vector2i, pool : EnemyPool, skipCount : bool = false):
	if tile_pos.x >= map_size.x + bounds_offset.x || tile_pos.y >= map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y:
		return
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(tile_pos / chunk_size) - chunk_origin
	
	var new_tile : Sprite2D = enemy_mask_object.instantiate()
	layer_groups[5].add_child(new_tile)
	set_editable_instance(new_tile, true)
	new_tile.visible = true
	new_tile.global_position = tile_pos * 32 + Vector2i(16,16)
	new_tile.pool = pool
	
	match pool.id:
		1: new_tile.modulate = Color(1 , 0.3 , 0.3 , 0.4)
		2: new_tile.modulate = Color(0.3 , 1 , 0.3 , 0.4)
		3: new_tile.modulate = Color(0.3 , 0.3 , 1 , 0.4)
		4: new_tile.modulate = Color(1 , 1 , 0.3 , 0.4)
		5: new_tile.modulate = Color(1 , 0.3 , 1 , 0.4)
		6: new_tile.modulate = Color(0.3 , 1 , 1 , 0.4)
	
	if !skipCount:
		var prev_tile : Node2D = layer_groups[5].layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
		if prev_tile:
			var prev_pool : EnemyPool = prev_tile.pool
			var idx_1 := prev_pool.enemy_mask_tiles_x.bsearch(tile_pos.x - 1, false)
			var idx_2 := prev_pool.enemy_mask_tiles_x.bsearch(tile_pos.x, false)
			var idx := prev_pool.enemy_mask_tiles_y.slice(idx_1,idx_2).bsearch(tile_pos.y) + idx_1
			prev_pool.enemy_mask_tiles_x.remove_at(idx)
			prev_pool.enemy_mask_tiles_y.remove_at(idx)
			prev_tile.queue_free()
		
		var idx_1 := pool.enemy_mask_tiles_x.bsearch(tile_pos.x - 1, false)
		var idx_2 := pool.enemy_mask_tiles_x.bsearch(tile_pos.x, false)
		var idx := pool.enemy_mask_tiles_y.slice(idx_1,idx_2).bsearch(tile_pos.y) + idx_1
		pool.enemy_mask_tiles_x.insert(idx, tile_pos.x)
		pool.enemy_mask_tiles_y.insert(idx, tile_pos.y)
		
	layer_groups[5].layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y] = new_tile

func EraseEnemyMaskTile(pool : EnemyPool, tile_pos : Vector2i):
	var idx_1 := pool.enemy_mask_tiles_x.bsearch(tile_pos.x - 1, false)
	var idx_2 := pool.enemy_mask_tiles_x.bsearch(tile_pos.x, false)
	var idx := pool.enemy_mask_tiles_y.slice(idx_1,idx_2).bsearch(tile_pos.y) + idx_1
	pool.enemy_mask_tiles_x.remove_at(idx)
	pool.enemy_mask_tiles_y.remove_at(idx)

func GetPackedTileArray(layer : CanvasGroup, map_array_length : int) -> PackedByteArray:
	var packed_array : PackedByteArray = []
	
	packed_array.resize(map_array_length)
	
	var n = 0
	for chunk_col in layer.layer_array:
		for chunk in chunk_col:
			for col in chunk:
				for tile in col:
					if tile:
						packed_array[n] = boxel_id_list.find(tile.id) + 1
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
		layer.modulate.a = 1.0
	
	layer_groups[3].material.set_shader_parameter("is_editing", false)

func EraseAtPosition(tile_pos : Vector2i, layer_group : CanvasGroup, update_adjacent : bool = true) -> void:
	if tile_pos.x >= map_size.x + bounds_offset.x || tile_pos.y >= map_size.y + bounds_offset.y || tile_pos.x < bounds_offset.x || tile_pos.y < bounds_offset.y: 
		return
	
	var tile_array_index = tile_pos % chunk_size
	var tile_chunk_index = Vector2i(tile_pos / chunk_size) - chunk_origin
	var tile = layer_group.layer_array[tile_chunk_index.x][tile_chunk_index.y][tile_array_index.x][tile_array_index.y]
	
	if !tile: return
	if tile is EnemyMaskTile: EraseEnemyMaskTile(tile.pool, tile_pos)
	DestroyTile(tile)
	
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
		
		if update_adjacent:
			CreateTile(box_dimensions.position + Vector2i(x, -1), layer_group)
			CreateTile(box_dimensions.position + Vector2i(x, box_dimensions.size.y), layer_group)
	
	if update_adjacent:
		for y in box_dimensions.size.y:
			CreateTile(box_dimensions.position + Vector2i(-1, y), layer_group)
			CreateTile(box_dimensions.position + Vector2i(box_dimensions.size.x, y), layer_group)

func EnemyMaskShapeTool(box_dimensions : Rect2i, pool : EnemyPool) -> void:
	box_dimensions.position.x = maxi(box_dimensions.position.x, bounds_offset.x)
	box_dimensions.position.y = maxi(box_dimensions.position.y, bounds_offset.y)
	box_dimensions.size.x = mini(box_dimensions.size.x, map_size.x + bounds_offset.x)
	box_dimensions.size.y = mini(box_dimensions.size.y, map_size.y + bounds_offset.y)
	
	for x in box_dimensions.size.x:
		for y in box_dimensions.size.y:
			AddEnemyMaskTile(box_dimensions.position + Vector2i(x,y), pool)

func EnemyMaskShapeEraser(box_dimensions : Rect2i):
	box_dimensions.position.x = maxi(box_dimensions.position.x, bounds_offset.x)
	box_dimensions.position.y = maxi(box_dimensions.position.y, bounds_offset.y)
	box_dimensions.size.x = mini(box_dimensions.size.x, map_size.x + bounds_offset.x)
	box_dimensions.size.y = mini(box_dimensions.size.y, map_size.y + bounds_offset.y)
	
	for x in box_dimensions.size.x:
		for y in box_dimensions.size.y:
			EraseAtPosition(box_dimensions.position + Vector2i(x,y), layer_groups[5], false)

func DestroyTile(tile : Node2D) -> void:
	tile.queue_free()
	add_free_node(tile)
	query_free_nodes()

func WipeMap(new_chunk_size : Vector2i = Vector2i(0,0)) -> void:
	chunk_dimensions = new_chunk_size
	for layer in layer_groups:
		for child in layer.get_children():
			child.queue_free()
		
		layer_init(layer, true)

func WriteLevelFile(filepath : String, filename : String, enemy_pool_tray : Control):
	print_rich("\n\n[b]=== Starting Level File Write ===[/b]")
	print("Writing to: ", filepath)
	print("Level name: ", filename)
	
	var file = FileAccess.open(filepath, FileAccess.WRITE_READ)
	file.resize(0)
	
	var filename_buff := filename.to_utf8_buffer()
	file.store_8(filename_buff.size())
	file.store_buffer(filename_buff)
	file.store_string("\n")
	
	var version_buff := "v0.2.1".to_utf8_buffer()
	print("Version: ", version_buff.get_string_from_utf8())
	file.store_8(version_buff.size())
	file.store_buffer(version_buff)
	file.store_string("\n")
	
	## Metadata TBD
	file.store_string("\n")
	
	file.store_32(chunk_dimensions.x)
	file.store_32(chunk_dimensions.y)
	file.store_string("\n")
	
	var boxel_id_buffer : PackedByteArray = boxel_id_list.to_byte_array()
	file.store_32(boxel_id_buffer.size())
	file.store_buffer(boxel_id_buffer)
	file.store_string("\n")
	
	var map_array_length : int = chunk_dimensions.x * chunk_dimensions.y * chunk_size * chunk_size
	file.store_64(map_array_length)
	file.store_string("\n")
	
	for i in 3:
		var t_layer = layer_groups[i]
		var floor_tile_buff : PackedByteArray = GetPackedTileArray(t_layer, map_array_length)
		file.store_buffer(floor_tile_buff)
		file.store_string("\n")
	file.store_string("\n")
	
	var entity_id_buffer : PackedByteArray = entity_id_list.to_byte_array()
	#print("Entity ID list size: ", entity_id_buffer.size())
	#print("Entity ID list: ", entity_id_list)
	file.store_32(entity_id_buffer.size())
	file.store_buffer(entity_id_buffer)
	file.store_string("\n")
	
	for i in 2:
		var t_layer = layer_groups[i+3]
		var entity_count = t_layer.get_child_count()
		#print("Writing entity layer {layer} with {count} entities".format({"layer":t_layer.name, "count":entity_count}))
		file.store_32(entity_count)
		
		for entity in t_layer.get_children():
			CompileEntityBytes(file, entity)
		
		file.store_string("\n")
	file.store_string("\n")
	
	for pool_ui in enemy_pool_tray.get_children():
		var pool : EnemyPool = pool_ui.enemy_pool
		
		file.store_32(pool.enemy_ids.size())
		file.store_buffer(pool.enemy_ids.to_byte_array())
		file.store_buffer(pool.enemy_amounts.to_byte_array())
		file.store_string("\n")
		file.store_32(pool.enemy_mask_tiles_x.size())
		file.store_buffer(pool.enemy_mask_tiles_x.to_byte_array())
		file.store_buffer(pool.enemy_mask_tiles_y.to_byte_array())
		file.store_string("\n")
	
	file.close()
	print_rich("[b]=== Level File Write Complete ===")


func CompileEntityBytes(file : FileAccess, entity : Node) -> void:
	print("=== Compiling Entity Bytes {name} ===".format(entity))
	var file_init = file.get_position()
	var id = entity.id
	file.store_32(id)
	file.store_32(entity.position.x)
	file.store_32(entity.position.y)
	file.store_32(entity.rotation)

	
	var def_idx := SceneLoadingContainer.loaded_entities.entity_ids.bsearch(id)
	if SceneLoadingContainer.loaded_entities.entity_ids[def_idx] != id: 
		file.store_8(0)
		print("No valid ID.\n")
		return
	
	var def_args = SceneLoadingContainer.loaded_entities.entity_arg_list[def_idx]
	print("Default args: ", def_args)
	var bit_flags = 0
	var args : Dictionary = entity.GetArgs()
	print("Entity args: ", args)
	
	var init_pointer := file.get_position()
	file.store_8(0)
	for i in def_args.size():
		var key = def_args.keys()[i]
		var value = args[key]
		if value && value != def_args[key]: 
			bit_flags |= ( 1 << i )
			file.store_var(value)
	
	var after_pointer := file.get_position()
	file.seek(init_pointer)
	file.store_8(bit_flags)
	file.seek(after_pointer)
	#print("Final bit flags: ", bit_flags)
	#print("Final entity bytes: ", file.get_position() - file_init)
	#print("=== Entity Bytes Compilation Complete ===")

func ReadLevelFile(filepath : String):
	print_rich("\n\n[b]=== Opening Level File (" + filepath + ") ===[/b]")
	var file = FileAccess.open(filepath, FileAccess.READ)
	
	# Read level name
	var lvl_namesize = file.get_8()
	var lvl_name = file.get_buffer(lvl_namesize).get_string_from_utf8()
	file.seek(file.get_position() + 1)
	print("Level Name: ", lvl_name)
	
	# Read version
	var version_size = file.get_8()
	var version = file.get_buffer(version_size).get_string_from_utf8()
	print("Version: ", version)
	file.seek(file.get_position() + 2)
	
	# Read chunk dimensions
	var chunks_size : Vector2i = Vector2i(0,0)
	chunks_size.x = file.get_32()
	chunks_size.y = file.get_32()
	WipeMap(chunks_size)
	
	var map_size = chunks_size * chunk_size
	map_size = map_size
	chunk_origin = Vector2i(0,0)
	bounds_offset = Vector2i(0,0)
	file.seek(file.get_position() + 1)
	
	# Read ID list
	var id_list_size = file.get_32()
	var id_list_buffer : PackedByteArray = file.get_buffer(id_list_size)
	file.seek(file.get_position() + 1)
	
	boxel_id_list.resize(id_list_size >> 2)
	boxel_usage_list.resize(id_list_size >> 2)
	boxel_usage_list.fill(0)
	
	for i in id_list_size >> 2:
		boxel_id_list[i] = id_list_buffer.decode_u32(i << 2)
	
	# Load boxels
	var temp_boxel_load_list : Array[LvlObject] = []
	for boxel_id in boxel_id_list:
		var new_index = boxel_id_list.bsearch(boxel_id)
		temp_boxel_load_list.append(loaded_object_list[new_index])
	
	# Read map array
	var map_array_length = file.get_64()
	file.seek(file.get_position() + 1)
	
	# Read tile layers
	for i in 3:
		var t_layer = layer_groups[i]
		var floor_tile_buff : PackedByteArray = file.get_buffer(map_array_length)
		
		var read_result = ReadPackedTileArray(t_layer, floor_tile_buff, temp_boxel_load_list)
		
		if read_result != "": 
			print("Error reading tile layer ", i, ": ", read_result)
		file.seek(file.get_position() + 1)
	file.seek(file.get_position() + 1)
	
	# Read entity ID list
	var eid_list_size = file.get_32()
	var eid_list_buffer : PackedByteArray = file.get_buffer(eid_list_size)
	file.seek(file.get_position() + 1)
	
	entity_id_list.resize(eid_list_size >> 2)
	entity_usage_list.resize(eid_list_size >> 2)
	entity_usage_list.fill(0)
	
	for i in eid_list_size >> 2:
		entity_id_list[i] = eid_list_buffer.decode_u32(i << 2)
	
	print("")
	# Read entity layers
	for i in 2:
		print("Reading entity layer ", i)
		var t_layer = layer_groups[i+3]
		var entity_count = file.get_32()
		print("Entity count in layer ", i, ": ", entity_count)
		
		for n in entity_count:
			var id = file.get_32()
			var entity_pos = Vector2()
			entity_pos.x = file.get_32()
			entity_pos.y = file.get_32()
			var entity_rot = file.get_32()
			
			var index = SceneLoadingContainer.loaded_entities.entity_ids.bsearch(id)
			var ref_args = SceneLoadingContainer.loaded_entities.entity_arg_list[index]
			var entity_arg_flags = file.get_8()
			print("Entity ", n, " - ID: ", id, " Position: ", entity_pos, " - args: ", entity_arg_flags)
			
			var args = {}
			if entity_arg_flags > 0:
				for k in 8:
					if entity_arg_flags & (1 << k): 
						
						args[ref_args.keys()[k]] = file.get_var()
			
			var new_entity = AddEntity(SceneLoadingContainer.loaded_entities.entity_ids[index], t_layer, entity_pos, args)
			new_entity.rotation = entity_rot
		
		file.seek(file.get_position() + 1)
	file.seek(file.get_position() + 1)
	
	for n in 6:
		var pool : EnemyPool = EnemyPool.new()
		
		var eid_size := file.get_32()
		var eid_buff := file.get_buffer(eid_size << 2)
		var e_amount_buff := file.get_buffer(eid_size << 2)
		file.seek(file.get_position() + 1)
		
		pool.enemy_ids = eid_buff.to_int32_array()
		pool.enemy_amounts = e_amount_buff.to_int32_array()
		
		var etile_size = file.get_32()
		var etile_buff_x = file.get_buffer(etile_size << 2)
		var etile_buff_y = file.get_buffer(etile_size << 2)
		file.seek(file.get_position() + 1)
		
		pool.enemy_mask_tiles_x = etile_buff_x.to_int32_array()
		pool.enemy_mask_tiles_y = etile_buff_y.to_int32_array()
		
		for i in pool.enemy_mask_tiles_x.size():
			AddEnemyMaskTile(Vector2i(pool.enemy_mask_tiles_x[i], pool.enemy_mask_tiles_y[i]), pool, true)
	
	print_rich("[b]Level file reading complete[/b]")
	file.close()

func SortBoxels():
	loaded_object_list.sort_custom(func(b1, b2): return b1.id > b2.id)

func AssignTileOwner() -> void:
	for layer in layer_groups:
		layer.owner = level_save_root
		for child in layer.get_children():
			child.owner = level_save_root

func AddEntity(obj_id : int, layer_group : CanvasGroup, pos : Vector2 = Vector2.ZERO, args : Dictionary = {}) -> Entity:
	var index : int = SceneLoadingContainer.loaded_entities.entity_ids.find(obj_id)
	var entity = SceneLoadingContainer.loaded_entities.entities[index].instantiate()
	
	if args.size() > 0: entity.MapArgs(args)
	layer_group.add_child(entity)
	
	entity.position = pos
	
	var id = entity.id
	var id_index := entity_id_list.bsearch(id)
	if entity_id_list.size() > id_index && id == entity_id_list[id_index]: entity_usage_list[id_index] += 1
	else: 
		entity_id_list.insert(id_index, id)
		entity_usage_list.insert(id_index, 1)
	
	return entity

func DeleteEntity(entity : Entity) -> void:
	var id = entity.id
	var index := entity_id_list.bsearch(id)
	if id == entity_id_list[index]: entity_usage_list[index] -= 1
	if entity_usage_list[index] <= 0: entity_usage_list.remove_at(index)
	
	entity.queue_free()

func GetIndexSpawnTile(pool : EnemyPool, tile_pos : Vector2i) -> int:
	return 0
	var mid : int = pool.enemy_mask_tiles_x.bsearch(tile_pos.x)
	var left : int
	var right : int
	for i in pool.enemy_mask_tiles_x.size():
		if pool.enemy_mask_tiles_x[mid - i] != tile_pos.x: 
			left = mid - i + 1
			break
	
	for i in pool.enemy_mask_tiles_x.size():
		if pool.enemy_mask_tiles_x[mid + i] != tile_pos.x: 
			right = mid + i - 1
			break

func GetNearestObjects(object_layer : CanvasGroup, t_point : Vector2, max_distance : float, exclusive : bool = false) -> Array:
	if exclusive:
		var closest : Node2D = null
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

func SpawnAllEnemiesInPool(pool : EnemyPool):
	for i in pool.enemy_ids.size():
		var e_id : int = pool.enemy_ids[i]
		var amount : int = pool.enemy_amounts[i]
		var enemy_prefab : PackedScene = SceneLoadingContainer.loaded_entities.entities[SceneLoadingContainer.loaded_entities.entity_ids.find(e_id)]
		
		var spawn_candidates : Array[Vector2i] = []
		var rng = RandomNumberGenerator.new()
		
		for n in amount:
			var idx = rng.randi_range(0, pool.enemy_mask_tiles_x.size() - 1)
			var new_pos = Vector2i(pool.enemy_mask_tiles_x[idx], pool.enemy_mask_tiles_y[idx])
			if spawn_candidates.find(new_pos) == -1:
				spawn_candidates.append(new_pos)
		
		for pos in spawn_candidates:
			var new_enemy = enemy_prefab.instantiate()
			layer_groups[3].add_child(new_enemy)
			new_enemy.position = Vector2(pos * 32) + Vector2(0.5,0.5)
