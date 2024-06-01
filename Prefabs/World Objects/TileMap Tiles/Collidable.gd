extends Sprite2D

@export var Health : int = 100

func TakeDamage(damage):
	Health -= damage
	if Health <= 0:
		$"..".DestroyTile(self)
