extends Control

var selected : Tile

func SelectTile(selected_tile : Tile):
	if selected_tile == selected:
		selected_tile.tile_highlighter.visible = false
		selected = null
		return
	
	for tile in get_children():
		tile.tile_highlighter.visible = (tile == selected_tile)
		if tile.tile_highlighter.visible:
			selected = tile
