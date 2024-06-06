extends Node2D

@export var timePerSpawn : float = 1
@export var enemyObjectResource : Resource
@export var spawning : bool = true
@export var spawnOnStart : bool = true


@onready var enemyObject : Object = preload("res://Prefabs/Enemies/enemy.tscn")
@onready var loaded_sprite : Object = preload("res://Prefabs/Enemies/Ememy Entity Sprites/generic_enemy_sprite.tscn")
var spawnTime : float

func _ready():
	spawnTime = timePerSpawn
	if spawnOnStart:
		Spawn()

func _physics_process(delta):
	if spawning:
		spawnTime -= delta
	
	if spawnTime <= 0.0:
		Spawn()

func Spawn():
	spawnTime += timePerSpawn
	var newEnemy = enemyObject.instantiate()
	var newEnemySprite = loaded_sprite.instantiate()
	add_child(newEnemy)
	$"..".masked_entity_container.add_child(newEnemySprite)
	newEnemy.global_position = global_position
	newEnemySprite.global_position = global_position
	
	newEnemy.entity_layer_sprite = newEnemySprite
