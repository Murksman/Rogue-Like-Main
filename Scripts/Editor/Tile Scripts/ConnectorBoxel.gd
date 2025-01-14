extends Boxel
class_name ConnectorBoxel

@export var tile_array : Array[TileInfo]

func GetConnectedTile(tile_index : int):
	var boxel_index = LevelInfo.connector_boxel_matrix[tile_index]
	return tile_array[boxel_index]
