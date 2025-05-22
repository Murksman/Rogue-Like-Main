@tool

extends Resource
class_name EntityImportTable

@export_group("Entity Info")
@export var entities : Array[PackedScene]
@export var entity_ids : PackedInt64Array
@export var entity_arg_list : Array[Dictionary]

@export_group("Utility")
@export var compile_entities := false:
	set(args):
		compile_entities = false
		CompileEntities()


func CompileEntities() -> void:
	if !Engine.is_editor_hint(): return
	
	entities = []
	entity_ids = []
	entity_arg_list = []
	
	var entity_paths = DirAccess.get_files_at("res://Prefabs/World Objects/Lvl Entities")
	
	for path in entity_paths:
		var load_path = "res://Prefabs/World Objects/Lvl Entities/" + path
		var load_result = ResourceLoader.load(load_path)
		
		if load_result is PackedScene:
			entities.append(load_result)
			
			var tmp_obj = load_result.instantiate()
			entity_ids.append(tmp_obj.id)
			entity_arg_list.append({})
		else:
			printerr("Entity Loading Error Code: ", load_result)
