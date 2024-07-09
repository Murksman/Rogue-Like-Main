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
@export var projectileContainer : Node2D

var orientation = Node2D
var player = CharacterBody2D

var projectileObject : Object
var projectileHitObject : Object
var rng = RandomNumberGenerator.new()

var fireTime : float = 0.0
var selected = false
var itemized = false
var preFiring = false
var currentMagAmmo : int
var currentAmmoReserve : int
var reloading = false
var reloadTime : float = 0.0


func _ready(): 
	currentMagAmmo = magazineSize
	rng.randomize()
	projectileObject = load(str(projectileHitObjectResource.resource_path))
	projectileHitObject = load(str(projectileHitObjectResource.resource_path))

func _physics_process(delta):
	if !itemized && selected && !player.ui_open:
		if reloading:
			reloadTime -= delta
			reloadTime = clamp(reloadTime, 0, reloadSpeed) 
			if reloadTime == 0: 
				ReloadEnd() 
		InputActions(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func InputActions(delta):
	var triggerHeld = Input.is_action_pressed("Primary")
	var triggerPressed = Input.is_action_just_pressed("Primary")
	fireTime -= delta
	if currentMagAmmo < magazineSize && Input.is_action_just_pressed("Reload") && !reloading:
		ReloadStart()
	if reloading && triggerPressed && currentMagAmmo != 0:
		ReloadCancel()
	if triggerHeld && !preFiring && currentMagAmmo > 0 && !reloading:
		if fireMode == "Full Auto" && fireTime <= 0:
			Shoot()
		if triggerPressed && fireMode == "Semi Auto":
			if fireTime <= 0:
				Shoot()
			elif fireTime <= 0.2 * fireRate:
				preFiring = true
	else:
		fireTime = clamp(fireTime, 0, fireRate)
		if preFiring && fireTime == 0 && currentMagAmmo > 0 && !reloading:
			Shoot()

func Shoot():
	currentMagAmmo -= 1
	preFiring = false
	fireTime += fireRate
	for i in baseProjectiles:
		var n : float = i
		var lookTheta = orientation.transform.x.angle_to(Vector2(1, 0))
		var theta
		if isSpreadRandom:
			theta = PI * rng.randf_range(-spreadRange, spreadRange) - lookTheta
		else:
			theta = PI * (n + 0.5 - baseProjectiles / 2.0) * spreadRange - lookTheta
		var x = cos(theta)
		var y = sin(theta)
		var direction = Vector2(x, y)
		var newBullet = projectileObject.instantiate()
		projectileContainer.add_child(newBullet)
		newBullet.global_position = global_position + orientation.transform.x
		newBullet.look_at(newBullet.global_position + direction)
		newBullet.addStats(projectileVelocity + rng.randf_range(projRandVelocityRange.x, projRandVelocityRange.y), direction, baseDamage, projectileMaxTime, numberOfBounces)

func ReloadStart():
	reloading = true
	preFiring = false
	reloadTime = reloadSpeed

func ReloadEnd():
	reloading = false
	var ammoSpace = magazineSize - currentMagAmmo 
	var reloadAmount = clamp(ammoSpace, 0, bulletsPerReload) 
	currentAmmoReserve -= reloadAmount 
	currentMagAmmo += reloadAmount
	if currentMagAmmo < magazineSize && continuousReload:
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
