extends HSplitContainer

func _on_dragged(offset: int) -> void:
	var space : int = offset - 24
	$"Tile Tray/Tile Tray Container/Tray Scroller/Tray Grid".columns = floor(space / 86)
