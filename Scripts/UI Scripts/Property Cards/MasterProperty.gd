extends VBoxContainer

@export var editor_layer : CanvasLayer

func Update(single_prop : Node = null) -> void:
	if single_prop:
		editor_layer.selected_world_obj.MapArgs({ single_prop.prop_title.text : single_prop.val })
	else:
		var arg_list = {}
		for prop in get_children():
			arg_list[prop.prop_title.text] = single_prop.val
		
		editor_layer.selected_world_obj.MapArgs(arg_list)
