extends LvlObject
class_name LightObject

@export var light_type : int = 0
@export var property_list : Dictionary = {}

func StitchFullTexture() -> CanvasTexture:
	return img
