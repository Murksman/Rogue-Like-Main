@icon("res://Sprites/Generic Objects/Icons/GunClass Icon.png")
extends Node2D
class_name Weapon

@export_group("Gun Bahavior")
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

@export_group("Ammo Behaviour")
@export var continuousReload: bool
@export var reloadSpeed : float
@export var magazineSize : int
@export var totalAmmoCapacity : int
@export var startingAmmo : int
@export var bulletsPerReload : int

@export_group("Weapon Resources")
@export var projectileObjectResource : Resource
@export var projectileHitObjectResource : Resource

@export_group("Modifiers")
@export var mod : Modifier

@onready var projectileContainer : Node2D = get_tree().current_scene.projectile_container

var orientation = Node2D
var player = CharacterBody2D

var projectileObject : Object
var projectileHitObject : Object
var rng = RandomNumberGenerator.new()

var fireTime : float = 0.0
var selected = false
var itemized = false
var preFiring = false
var currentMagAmmo : int = 0
var currentAmmoReserve : int = 0
var reloading = false
var reloadTime : float = 0.0

@onready var t_fire_mode : String =	fireMode
@onready var t_projectiles : float = baseProjectiles
@onready var t_is_spread_random : bool = isSpreadRandom
@onready var t_spread_range : float = spreadRange
@onready var t_fire_rate : float = fireRate
@onready var t_damage : float = baseDamage
@onready var t_projectile_velocity : float = projectileVelocity
@onready var t_proj_rand_velocity_range : Vector2 = projRandVelocityRange
@onready var t_projectile_max_time : float = projectileMaxTime
@onready var t_number_of_bounces : int = numberOfBounces
@onready var t_continuous_reload: bool = continuousReload
@onready var t_reload_speed : float = reloadSpeed
@onready var t_magazine_size : int = magazineSize
@onready var t_total_ammo_capacity : int = totalAmmoCapacity
@onready var t_starting_ammo : int = startingAmmo
@onready var t_bullets_per_reload : int = bulletsPerReload

@onready var t_projectileObjectResource : Resource = projectileObjectResource
@onready var t_projectileHitObjectResource : Resource = projectileHitObjectResource


func CalculateStats(use_mod : bool = true):
	var stats_status : int = 0
	
	if mod == null || !use_mod: return
	
	stats_status = mod.SetStats(self)
	
	if stats_status == 0: return

func _ready(): 
	CalculateStats(true)
	
	currentMagAmmo = t_magazine_size
	
	rng.randomize()
	
	projectileObject = load(str(t_projectileObjectResource.resource_path))
	projectileHitObject = load(str(t_projectileHitObjectResource.resource_path))

func _physics_process(delta):
	if !itemized && selected && !player.ui_open:
		if reloading:
			reloadTime -= delta
			reloadTime = clamp(reloadTime, 0, t_reload_speed) 
			if reloadTime == 0: 
				ReloadEnd() 
		InputActions(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func InputActions(delta):
	var triggerHeld = Input.is_action_pressed("Primary")
	var triggerPressed = Input.is_action_just_pressed("Primary")
	
	fireTime -= delta
	
	if currentMagAmmo < t_magazine_size && Input.is_action_just_pressed("Reload") && !reloading:
		ReloadStart()
	if reloading && triggerPressed && currentMagAmmo != 0:
		ReloadCancel()
	if triggerHeld && !preFiring && currentMagAmmo > 0 && !reloading:
		if t_fire_mode == "Full Auto" && fireTime <= 0:
			Shoot()
		if t_fire_mode == "Semi Auto" && triggerPressed:
			if fireTime <= 0:
				Shoot()
			elif fireTime <= 0.2 * t_fire_rate:
				preFiring = true
	else:
		fireTime = clamp(fireTime, 0, t_fire_rate)
		if preFiring && fireTime == 0 && currentMagAmmo > 0 && !reloading:
			Shoot()

func Shoot():
	currentMagAmmo -= 1
	preFiring = false
	fireTime += t_fire_rate
	for i in t_projectiles:
		var lookTheta = orientation.transform.x.angle_to(Vector2(1, 0))
		var theta
		if t_is_spread_random:
			theta = PI * rng.randf_range(-t_spread_range, t_spread_range) - lookTheta
		else:
			theta = PI * (i + 0.5 - t_projectiles / 2.0) * t_spread_range - lookTheta
		var x = cos(theta)
		var y = sin(theta)
		var direction = Vector2(x, y)
		var newBullet = projectileObject.instantiate()
		projectileContainer.add_child(newBullet)
		newBullet.global_position = global_position + orientation.transform.x
		newBullet.look_at(newBullet.global_position + direction)
		newBullet.addStats(t_projectile_velocity + rng.randf_range(t_proj_rand_velocity_range.x, t_proj_rand_velocity_range.y), direction, t_damage, t_projectile_max_time, t_number_of_bounces)

func ReloadStart():
	reloading = true
	preFiring = false
	reloadTime = t_reload_speed

func ReloadEnd():
	reloading = false
	var ammoSpace = t_magazine_size - currentMagAmmo 
	var reloadAmount = clamp(ammoSpace, 0, t_bullets_per_reload) 
	currentAmmoReserve -= reloadAmount 
	currentMagAmmo += reloadAmount
	if currentMagAmmo < t_magazine_size && t_continuous_reload:
		ReloadStart()

func ReloadCancel():
	reloading = false
	reloadTime = 0.0

func Deselect():
	ReloadCancel()
	selected = false
	visible = false

func Select(parent_player, parent_orientation):
	orientation = parent_orientation
	player = parent_player
	$"../..".selected_weapon = self
	selected = true
	visible = true

 
func ChangeItem(is_item):
	itemized = is_item
	
	get_child(0).visible = !itemized
	get_child(1).visible = itemized
