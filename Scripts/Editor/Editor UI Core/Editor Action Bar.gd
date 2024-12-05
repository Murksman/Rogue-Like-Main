extends HSplitContainer

@export var tray_grid : GridContainer

func _on_dragged(offset: int) -> void:
	var space : int = offset - 24
	tray_grid.columns = floor(space / 86)
