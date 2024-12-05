extends Boxel
class_name ScatterBoxel

var tile_info_array : Array[TileInfo]

func GetTileInfo() -> TileInfo:
	return tile_info_array.pick_random()
