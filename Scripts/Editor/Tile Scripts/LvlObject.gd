extends Resource
class_name LvlObject

@export var img : CanvasTexture
@export var name : StringName
@export var layers : Array[int] = []
@export var id : int = 0

func GetTileInfo() -> TileInfo:
	return null

func ContainsLayer(layer) -> bool:
	return layers.has(layer)
