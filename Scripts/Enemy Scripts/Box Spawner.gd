extends Spawner
class_name EnemyBoxSpawner

@export var spawning_dimensions : Vector2i
@export var spawning_random_density : Vector2i

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	spawnTime = timePerSpawn
	
	rng.randomize()
	
	#if spawnOnStart:
		#SpawnCalc()


func SpawnCalc(intensity):
	for i in rng.randi_range(spawning_random_density.x, spawning_random_density.y * intensity):
		var spawnX = rng.randf_range(0, spawning_dimensions.x)
		var spawnY = rng.randf_range(0, spawning_dimensions.y)
		Spawn(global_position + (Vector2(spawnX, spawnY) * 32))

func _physics_process(delta):
	pass
	#if spawning:
		#spawnTime -= delta
		#if spawnTime <= 0.0:
			#SpawnCalc()
