extends Button

@export var select_layer : CanvasGroup
@export var layer_int : int

func _pressed() -> void:
	var pressed : Button = button_group.get_pressed_button()
	if pressed: 
		for button in button_group.get_buttons():
			if button == pressed: button.select_layer.modulate.a = 1.0
			else: button.select_layer.modulate.a = 0.3
	else:
		for button in button_group.get_buttons():
			button.select_layer.modulate.a = 1.0
	
	$"../../../..".ChangeLayer(layer_int)
