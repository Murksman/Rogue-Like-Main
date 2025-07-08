extends PanelContainer

@export var editor_layer : CanvasLayer
@export var prop_stack : VBoxContainer

@export var int_prop : PackedScene
@export var float_prop : PackedScene
@export var string_prop : PackedScene
@export var color_prop : PackedScene

func Update(single_prop : Node = null) -> void:
	if single_prop:
		editor_layer.selected_world_obj.MapArgs({ single_prop.prop_title.text : single_prop.val })
	else:
		var arg_list = {}
		for prop in get_children():
			arg_list[prop.prop_title.text] = prop.val
		
		editor_layer.selected_world_obj.MapArgs(arg_list)

func Reset(new_obj : Entity):
	var new_args = new_obj.GetArgs()
	
	for child in prop_stack.get_children(): child.queue_free()
	
	var values = new_args.values()
	var keys = new_args.keys()
	
	for i in new_args.size():
		var val = values[i]
		var key = keys[i]
		
		var new_prop : Control
		if val is int: new_prop = int_prop.instantiate()
		if val is float: new_prop = float_prop.instantiate()
		if val is String: new_prop = string_prop.instantiate()
		if val is Color: new_prop = color_prop.instantiate()
		
		new_prop.Update(val)
		new_prop.prop_title.text = str(key)
		
		prop_stack.add_child(new_prop)
