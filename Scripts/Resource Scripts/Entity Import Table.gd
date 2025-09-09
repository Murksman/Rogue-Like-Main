@tool

extends Resource
class_name EntityImportTable

@export_group("Entity Info")
@export var entities : Array[PackedScene]
@export var entity_ids : PackedInt64Array
@export var entity_arg_list : Array[Dictionary]
@export var enemy_eids : PackedInt64Array

@export_group("Utility")
@export var new_entity_id : int ## Leavw 0 for automatic selection
@export var new_entity_resource : PackedScene ## Leavw 0 for automatic selection
@export var new_entity_args : Dictionary = {} ## Leavw 0 for automatic selection
@export var new_is_enemy : bool = false
@export var add_new_entity : bool = false:
	set(args):
		if !new_entity_resource: return
		
		var new_id = 0
		var idx = 0
		if new_entity_id == 0:
			for i in 100000:
				if entity_ids.find(i+1) == -1:
					new_id = i+1
					idx = entity_ids.bsearch(new_id)
					entity_ids.insert(idx, new_id)
					break
		else: 
			new_id = new_entity_id
			idx = entity_ids.bsearch(new_entity_id)
			entity_ids.insert(idx, new_entity_id)
		
		entities.insert(idx, new_entity_resource)
		entity_arg_list.insert(idx, new_entity_args)
		
		if new_is_enemy: enemy_eids.insert(enemy_eids.bsearch(new_id), new_id)
		
		new_entity_id = 0
		new_entity_resource = null
		new_entity_args = {}
		new_is_enemy = false
		add_new_entity = false

#@export var compile_entities := false:
	#set(args):
		#compile_entities = false
		#CompileEntities()

func CompileEntities() -> void:
	if !Engine.is_editor_hint(): return
	var tmp_args_list := entity_arg_list.duplicate()
	var tmp_args_ids := entity_ids.duplicate()
	
	entities = []
	entity_ids = []
	
	var entity_paths = DirAccess.get_files_at("res://Prefabs/World Objects/Lvl Entities")
	
	for path in entity_paths:
		var load_path = "res://Prefabs/World Objects/Lvl Entities/" + path
		var load_result = ResourceLoader.load(load_path)
		
		if load_result is PackedScene:
			var tmp_obj = load_result.instantiate()
			var index = entity_ids.bsearch(tmp_obj.id)
			entity_ids.insert(index, tmp_obj.id)
			entities.insert(index, load_result)
		else:
			printerr("Entity Loading Error Code: ", load_result)
