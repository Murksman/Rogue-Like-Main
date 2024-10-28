extends Sprite2D

@export var Health : int = 100
@export var breakable : bool = false
@export var occluder_child : LightOccluder2D

func TakeDamage(damage):
	if breakable:
		if Health - damage <= 0:
			occluder_child.queue_free()
			$"..".DestroyTile(self)
			return Health
		
		Health -= damage
		return damage
