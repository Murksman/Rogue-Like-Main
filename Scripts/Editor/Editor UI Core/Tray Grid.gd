extends GridContainer

var selected : UIBoxel
var hover_boxel : Control

@export var editor_overlay : CanvasLayer
@export var ui_boxel_prefab : PackedScene
@export var search_box : LineEdit

func SelectBoxel(selected_tile : UIBoxel):
	if selected_tile == selected:
		selected_tile.tile_highlighter.visible = false
		selected = null
		editor_overlay.selected_boxel = null
		return
	
	if selected: selected.tile_highlighter.visible = false
	
	selected_tile.tile_highlighter.visible = true
	selected = selected_tile
	editor_overlay.selected_boxel = selected

func MouseExit(target : Control):
	if target == hover_boxel:
		hover_boxel.name_label.visible = false
		hover_boxel = null

func HoverBoxel(hover_target : UIBoxel):
	if hover_boxel && hover_target != hover_boxel: 
		hover_boxel.name_label.visible = false
	hover_boxel = hover_target
	hover_target.name_label.visible = true

func AddNewBoxel(boxel_res : Boxel):
	var new_boxel : UIBoxel = ui_boxel_prefab.instantiate()
	new_boxel.owner = editor_overlay
	add_child(new_boxel)
	
	new_boxel.AddBoxel(boxel_res)
	
	queue_sort()

func ReorderBoxels(search_text : String = search_box.text, layer_button : Button = editor_overlay.layer_button_group.get_pressed_button()):
	var ui_boxels = get_children()
	
	if search_text == "":
		for child in ui_boxels:
			child.visible = true
	else:
		for child in ui_boxels:
			child.visible = child.boxel.boxel_name.contains(search_text)
	
	if layer_button:
		for child in ui_boxels:
			child.grayout.visible = !child.boxel.ContainsLayer(layer_button.layer_int)
	else:
		for child in ui_boxels:
			child.grayout.visible = false
	
