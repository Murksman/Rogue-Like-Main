extends Control

@export var tile_highlighter : Control
@export var enemy_pool : EnemyPool

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Primary") && event is InputEventMouseButton:
		if event.double_click:
			pass
		else:
			var curr_pool = LevelInfo.editor_ref.selected_enemy_pool
			
			if curr_pool == self:
				tile_highlighter.visible = false
				LevelInfo.editor_ref.selected_enemy_pool = null
			else:
				curr_pool.tile_highlighter.visible = false
				tile_highlighter.visible = true
				LevelInfo.editor_ref.selected_enemy_pool = self
