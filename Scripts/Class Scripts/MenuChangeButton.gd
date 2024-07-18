extends TextureButton

class_name MenuChangeButton

@export var target_menu_id : int


func _pressed():
	if owner is Control:
		owner.ChangeMenu(target_menu_id)
