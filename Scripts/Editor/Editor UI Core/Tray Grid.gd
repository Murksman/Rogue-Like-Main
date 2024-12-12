extends Control

var selected : UIBoxel
var hover_boxel : Control

@export var editor_overlay : CanvasLayer

func SelectTile(selected_tile : UIBoxel):
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
	if target != hover_boxel: return
	
	hover_boxel.name_label.visible = false
	hover_boxel = null

func HoverTile(hover_target : UIBoxel):
	if hover_boxel == hover_target: return
	if hover_boxel: hover_boxel.name_label.visible = false
	else: hover_boxel = hover_target
	
	hover_target.name_label.visible = true
