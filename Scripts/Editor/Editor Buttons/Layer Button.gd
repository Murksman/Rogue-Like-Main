extends Button

@export var select_layer : CanvasGroup
@export var layer_int : int

func _pressed() -> void:
	var pressed : Button = button_group.get_pressed_button()
	if pressed: 
		for button in button_group.get_buttons():
			ChangeLayerVisibility(button.select_layer, button == pressed)
	else:
		for button in button_group.get_buttons():
			ChangeLayerVisibility(button.select_layer, true)
	
	$"../../../..".library_grid.ReorderBoxels()

func ChangeLayerVisibility(layer : CanvasGroup, is_visible : bool):
	layer.material.set_shader_parameter("is_visible", is_visible)
