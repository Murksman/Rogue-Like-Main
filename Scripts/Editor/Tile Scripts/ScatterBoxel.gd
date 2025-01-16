extends Boxel
class_name ScatterBoxel

@export var tile_array : Array[TileInfo]

func GetTileInfo() -> TileInfo:
	return tile_array.pick_random()
