extends Control

@export var tile_highlighter : Control
@export var enemy_pool : EnemyPool

func _ready() -> void:
	enemy_pool = EnemyPool.new()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Primary") && event is InputEventMouseButton:
		if event.double_click:
			$"../../../..".OpenEnemyPool(enemy_pool)
		else:
			var curr_pool = LevelInfo.editor_ref.selected_enemy_pool
			
			if curr_pool: curr_pool.tile_highlighter.visible = false
			
			LevelInfo.editor_ref.selected_enemy_pool = self
			tile_highlighter.visible = true
