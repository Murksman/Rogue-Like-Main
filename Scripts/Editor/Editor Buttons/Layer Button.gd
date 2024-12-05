extends Button

@export var select_layer : CanvasGroup

func _pressed() -> void:
	if !button_group.get_pressed_button(): 
		for button in button_group.get_buttons():
			if !button.select_layer: continue
			
			ChangeLayerVisibility(button.select_layer, true)
		
		return
	
	for button in button_group.get_buttons():
		if !button.select_layer: continue
		
		ChangeLayerVisibility(button.select_layer, button_group.get_pressed_button() == button)

func ChangeLayerVisibility(layer : CanvasGroup, is_visible : bool):
	print(layer, is_visible)
	layer.material.set_shader_parameter("is_visible", is_visible)
