extends Sprite2D

@export var Health : int = 100
@export var breakable : bool = false
@export var occluder_child : LightOccluder2D

func _ready():
	print($"Wall Light Occluder".occluder.polygon)

func TakeDamage(damage):
	if breakable:
		Health -= damage
		if Health <= 0:
			occluder_child.queue_free()
			$"..".DestroyTile(self)
