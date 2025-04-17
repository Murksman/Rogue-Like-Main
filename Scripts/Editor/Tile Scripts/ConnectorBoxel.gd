extends LvlObject
class_name ConnectorBoxel

@export var tile_array : Array[TileInfo]
@export var breakable : bool = false
@export var tile_health : int = 0

func GetConnectedTile(tile_index : int):
	var boxel_index = LevelInfo.connector_boxel_matrix[tile_index]
	return tile_array[boxel_index]

func StitchFullTexture() -> CanvasTexture:
	var image_rect = Rect2i(0,0,32,32)
	
	var new_image = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	var new_normal = new_image.duplicate()
	
	for i in tile_array.size():
		var temp_image = tile_array[i].image.diffuse_texture.get_image()
		var temp_normal = tile_array[i].image.normal_texture.get_image()
		var offset = Vector2i(i % 4, i / 4) * 32
		new_image.blit_rect(temp_image, image_rect, offset)
		new_normal.blit_rect(temp_normal, image_rect, offset)
	
	var new_texture = CanvasTexture.new()
	new_texture.diffuse_texture = ImageTexture.create_from_image(new_image)
	new_texture.normal_texture = ImageTexture.create_from_image(new_normal)
	
	return new_texture
