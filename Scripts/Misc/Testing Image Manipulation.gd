extends Node2D

@export var test_img_1 : Texture2D
@export var test_img_2 : Texture2D

func _ready() -> void:
	#var new_image = Image.create(32,64,false, test_img_1.Format)
	var image_1 = test_img_1.get_image()
	var image_2 = test_img_2.get_image()
	image_1.crop(200,128)
	image_1.blit_rect(image_2, Rect2i(0,0,128,128), Vector2i(128,0))
	$Sprite2D.texture = ImageTexture.create_from_image(image_1)
