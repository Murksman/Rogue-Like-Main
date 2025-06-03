extends Node2D
class_name Spawner

@export var timePerSpawn : float = 1
@export var spawning : bool = false
@export var spawnOnStart : bool = true

@onready var enemyObject : Object = preload("res://Prefabs/Enemies/enemy.tscn")
var spawnTime : float

@export var id : int = 0

func MapArgs(args : Dictionary) -> int:
	return 1

func GetArgs() -> Dictionary:
	return {}

func Spawn(spawn_pos):
	spawnTime += timePerSpawn
	var newEnemy = enemyObject.instantiate()
	SceneLoadingContainer.enemy_container.add_child(newEnemy)
	newEnemy.global_position = spawn_pos
