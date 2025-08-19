extends Window

@export var lvl_list : Control
var curr_pool : EnemyPool

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"): notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: Close()

func _on_exit_button_pressed() -> void:
	notification(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_delete_pool_pressed() -> void:
	curr_pool.enemy_amounts = PackedInt32Array()
	curr_pool.enemy_ids = PackedInt32Array()
	curr_pool.enemy_mask_tiles = PackedVector2Array()
	
	for enemy_select in lvl_list.get_children():
		enemy_select.SetVal(0)

func Close():
	hide()
	visible = false

func Open(pool : EnemyPool):
	curr_pool = pool
	
	for enemy_select in lvl_list.get_children():
		var idx := curr_pool.enemy_ids.find(enemy_select.id)
		if idx > -1:
			enemy_select.SetVal(curr_pool.enemy_amounts[idx])
		else:
			enemy_select.SetVal(0)
	
	visible = true
	popup()


func _on_save_pool_pressed() -> void:
	for enemy_select in lvl_list.get_children():
		var idx := curr_pool.enemy_ids.bsearch(enemy_select.id)
		if curr_pool.enemy_ids.size() < 1 || curr_pool.enemy_ids[idx-1] != enemy_select.id:
			curr_pool.enemy_ids.insert(idx, enemy_select.id)
			curr_pool.enemy_amounts.insert(idx, enemy_select.val)
		else:
			curr_pool.enemy_amounts[idx] = enemy_select.val
	
	Close()
