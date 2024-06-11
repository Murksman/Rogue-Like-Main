extends Spawner
class_name EnemyBoxSpawner

@export var spawning_dimensions : Vector2i
@export var spawning_random_density : Vector2i

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	if spawnOnStart:
		SpawnCalc()


func SpawnCalc():
	for i in rng.randi_range(spawning_random_density.x, spawning_random_density.x):
		var spawnX = rng.randi_range(0, spawning_dimensions.x)
		var spawnY = rng.randi_range(0, spawning_dimensions.y)
		Spawn(global_position + Vector2(spawnX, spawnY))

func _physics_process(delta):
	if spawning:
		spawnTime -= delta
	
	if spawnTime <= 0.0:
		SpawnCalc()
