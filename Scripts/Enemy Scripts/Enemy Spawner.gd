extends Node2D

@export var timePerSpawn : float = 1
@export var enemyObjectResource : Resource
@export var spawning : bool = true
@export var spawnOnStart : bool = true

var enemyObject
var spawnTime : float

func _ready():
	spawnTime = timePerSpawn
	enemyObject = load(str(enemyObjectResource.resource_path))
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
	add_child(newEnemy)
	newEnemy.global_position = global_position
