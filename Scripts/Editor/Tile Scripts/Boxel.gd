extends Resource
class_name Boxel

@export var boxel_img : CanvasTexture
@export var boxel_name : StringName
@export var layers : Array[int] = []
@export var boxel_id : int = 0

func GetTileInfo() -> TileInfo:
	return null

func ContainsLayer(layer) -> bool:
	return layers.has(layer)
