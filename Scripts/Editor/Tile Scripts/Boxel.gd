extends Resource
class_name Boxel

@export var boxel_img : Texture2D
@export var boxel_name : String
@export var layers : Array[int] = []

func GetTileInfo() -> TileInfo:
	return null

func ContainsLayer(layer) -> bool:
	return layers.has(layer)
