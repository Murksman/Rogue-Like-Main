extends Spawner
class_name EnemyCircleSpawner

@export var spawning_radius : int
@export var spawning_random_density : Vector2i

@onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	spawnTime = timePerSpawn
	
	rng.randomize()
	
	if spawnOnStart:
		SpawnCalc()


func SpawnCalc():
	for i in rng.randi_range(spawning_random_density.x, spawning_random_density.x):
		var radius = sqrt(rng.randf_range(0, 1)) * spawning_radius
		var angle = rng.randf_range(0, 2 * PI)
		var polar_position = Vector2(cos(angle), sin(angle)) * radius * 32
		Spawn(global_position + polar_position)

func _physics_process(delta):
	if spawning:
		spawnTime -= delta
		if spawnTime <= 0.0:
			SpawnCalc()
