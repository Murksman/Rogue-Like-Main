extends Node2D

@export var player : Node2D
@export var masked_entity_container : Node2D

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	SpawnLevel(1)

func SpawnLevel(total_intensity):
	for child in get_children():
		child.SpawnCalc(total_intensity)
