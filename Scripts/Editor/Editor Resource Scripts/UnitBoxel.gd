extends LvlObject
class_name UnitBoxel

@export var tile_info : TileInfo

func GetTileInfo() -> TileInfo:
	return tile_info

func StitchFullTexture() -> CanvasTexture:
	return img
