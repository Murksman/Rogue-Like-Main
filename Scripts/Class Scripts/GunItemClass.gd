@icon("res://Sprites/Generic Objects/Icons/GunClass Icon.png")
extends Node2D
class_name WeaponItem

@export_group("Weapon Data")
@export_enum("Full Auto", "Semi Auto", "Pump/Bolt Action") var fireMode : String = "Full Auto"
@export var baseProjectiles : float = 1.0
@export var isSpreadRandom : bool = false
@export var spreadRange : float # Increments by factors of PI (ie. 1 = PI). Defines the maximum range the spread can reach. for non-random projectiles, This will stack creating an even "fan" of projecetiles.
@export var fireRate : float = 1 # measured in seconds
@export var baseDamage : float = 1
@export var projectileVelocity : float = 1
@export var projRandVelocityRange : Vector2
@export var projectileMaxTime : float = 1
@export var numberOfBounces : int = 0
@export var continuousReload: bool
@export var reloadSpeed : float
@export var magazineSize : int
@export var totalAmmoCapacity : int
@export var startingAmmo : int
@export var bulletsPerReload : int
@export var weapon_item : Node2D
@export var projectileObjectResource : Resource
@export var projectileHitObjectResource : Resource
@export var projectileContainer : Node2D
@export_exp_easing("attenuation") var test : float
