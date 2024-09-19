extends Node2D

@export var player : Node2D
@export var masked_entity_container : Node2D

@export var global_spawn_toggle : bool

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	if global_spawn_toggle: SpawnLevel(1)

func SpawnLevel(total_intensity):
	for child in get_children():
		child.SpawnCalc(total_intensity)
