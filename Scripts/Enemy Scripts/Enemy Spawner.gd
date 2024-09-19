extends Node2D
class_name Spawner

@export var timePerSpawn : float = 1
@export var enemyObjectResource : Resource
@export var spawning : bool = false
@export var spawnOnStart : bool = true

#@onready var spawn_area : Area2D = $"Area2D"
@onready var enemyObject : Object = preload("res://Prefabs/Enemies/enemy.tscn")
@onready var loaded_sprite : Object = preload("res://Prefabs/Enemies/Ememy Entity Sprites/generic_enemy_sprite.tscn")
var spawnTime : float


func Spawn(spawn_pos):
	spawnTime += timePerSpawn
	var newEnemy = enemyObject.instantiate()
	var newEnemySprite = loaded_sprite.instantiate()
	add_child(newEnemy)
	$"..".masked_entity_container.add_child(newEnemySprite)
	newEnemy.global_position = spawn_pos
	newEnemySprite.global_position = spawn_pos
	
	newEnemy.entity_layer_sprite = newEnemySprite
