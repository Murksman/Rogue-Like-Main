extends Container

@export var editor_overlay : CanvasLayer
@export var ui_boxel_prefab : PackedScene
@export var search_box : LineEdit

func AddNewBoxel(boxel_res : Boxel, boxel_res_path, importing):
	if importing:
		var new_boxel : UIBoxel = ui_boxel_prefab.instantiate()
		add_child(new_boxel)
		
		new_boxel.AddBoxel(boxel_res, boxel_res_path)
	else:
		for child in get_children():
			if child.boxel == boxel_res:
				child.AddBoxel(boxel_res) 
	
	queue_sort()

func ReorderBoxels(search_text : String = search_box.text, layer_button : Button = editor_overlay.layer_button_group.get_pressed_button()):
	var ui_boxels = get_children()
	
	var no_search : bool = search_text == ""
	var layer_int : int = 0
	if layer_button: layer_int = layer_button.layer_int
	
	if no_search && layer_button:
		for child in ui_boxels:
			child.visible = child.boxel.ContainsLayer(layer_int)
	elif no_search:
		for child in ui_boxels:
			child.visible = true
	elif layer_button:
		for child in ui_boxels:
			child.visible = child.boxel.boxel_name.contains(search_text) && child.boxel.ContainsLayer(layer_int)
	else:
		for child in ui_boxels:
			child.visible = child.boxel.boxel_name.contains(search_text)
