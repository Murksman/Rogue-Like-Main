extends TabContainer

@export var tab_visible_states : Array[bool] = [true,false,false]

func _ready() -> void:
	UpdateTabVisibility()

func UpdateTabVisibility(vis_state : Array[bool] = tab_visible_states):
	if tab_visible_states != vis_state: tab_visible_states = vis_state.duplicate()
	
	var all_tabs_hidden = true
	
	for i in vis_state.size():
		set_tab_hidden(i, !vis_state[i])
		if vis_state[i]: all_tabs_hidden = false
	
	visible = !all_tabs_hidden 
