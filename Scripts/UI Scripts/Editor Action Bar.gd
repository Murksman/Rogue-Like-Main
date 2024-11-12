extends VSplitContainer

func _ready() -> void:
	var grabber : GradientTexture2D = get("theme_override_icons/grabber")
	grabber.width = size.x
	print(grabber)
	set("theme_override_icons/grabber", grabber)
