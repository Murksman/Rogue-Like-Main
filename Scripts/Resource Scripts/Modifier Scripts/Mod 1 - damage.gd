extends Modifier
class_name Mod1_damage

var projectile : Projectile

func _init():
	mod_name = "Crazy Mod"
	mod_description = "adds damage \nincreases mag size \nmultiplies fire rate \nsets projectiles to one \nfires a different projectile"

func SetStats(weapon : Weapon) -> int:
	weapon.t_damage = 100
	weapon.t_magazine_size = 10
	weapon.t_fire_rate = weapon.fireRate / 10
	#weapon.fireMode = "Full Auto"
	weapon.t_projectiles = 1
	weapon.t_number_of_bounces = 10
	weapon.t_projectile_velocity = weapon.projectileVelocity * 0.2
	
	weapon.t_projectileObjectResource = load("res://Prefabs/Effect Objects/Player Projectiles/Dummy Stone.tscn")
	
	return 1

func PrimaryFire() -> int:
	return 1
