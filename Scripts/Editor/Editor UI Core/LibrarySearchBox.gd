extends LineEdit

@export var library_grid : GridContainer

var timer : float = 0

func _process(delta: float) -> void:
	print(timer)
	if timer > 0.0: 
		if timer - delta <= 0: UpdateBoxelSearch()
		timer -= delta

func UpdateBoxelSearch(search_text : String = text):
	if text == "":
		
	for child in library_grid.get_children():
		var boxel_name = child.boxel.boxel_name
		child.visible = boxel_name.contains(search_text)


func _on_text_changed(new_text: String) -> void:
	timer = 0.5
