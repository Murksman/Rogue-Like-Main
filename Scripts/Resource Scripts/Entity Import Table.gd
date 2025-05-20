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
	entities = []
	entity_ids = []
	entity_arg_list = []
	
	entity_ids
	
	var entity_paths = DirAccess.get_files_at(SceneLoadingContainer.entity_load_path)
	
	for path in entity_paths:
		var load_path = SceneLoadingContainer.entity_load_path + "/" + path
		var load_result = ResourceLoader.load(load_path)
		
		if load_result is PackedScene:
			entities.append(load_result)
			
			var tmp_obj = load_result.instantiate()
			entity_ids.append(tmp_obj.id)
			entity_arg_list.append({})
		else:
			printerr("Entity Loading Error Code: ", load_result)
