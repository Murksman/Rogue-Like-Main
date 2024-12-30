extends LineEdit

@export var library_grid : GridContainer

var timer : float = 0

func _process(delta: float) -> void:
	if timer > 0.0: 
		if timer - delta <= 0: library_grid.ReorderBoxels(text)
		timer -= delta


func _on_text_changed(new_text: String) -> void:
	timer = 0.2
