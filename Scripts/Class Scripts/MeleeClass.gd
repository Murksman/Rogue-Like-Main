@icon("res://Sprites/Generic Objects/Icons/Melee Icon.png")
extends Node2D
class_name MeleeWeapon

@export_group("Weapon Stats")
@export var baseDamage : float
@export var weight : float  ## How much the weapon "weighs". A higher values means the weapon will swing around slower and less responsive (inversely proportional) 
@export var velocityDamageMulti : float

@export_category("Swing Behavior")
@export var swingForceCurve : Curve  ## Converts the angle between your cursor and the weapon to a "force" that accelerates the weapon. 
@export var swingForceMaxAngle : float  ## Scales the angle used in the swingForceCurve to the maximum angle that the player can reach before maximum force is applied (1 = 180 degrees) 
@export var swingDrag : float  ## Applies drag which slows the weapon down and caps top speed at weight/swingDrag radians/second due to the converging sum of the two functions
@export var maximumMomentum : float ## Caps momentum.
@export var stopForce : float ## Dampens the velocity when the weapon passes near the cursor to bring it to rest quicker
@export var collisionPadding : float ## multiplies the velocity of the rebound after a collision with an enemy

@export_group("Melee Animation")
@export var holsterCurve : Curve ## 1 = start, 0 = finish
@export var unholsterSpeed : float ## Measured in seconds to unholster.
@export var holsterSpeed : float ## Measured in seconds to holster.
@export var holsterPositions : Vector2 ## x = holstered, y = unholstered. position relative to look direction (tranform x) that extends from the front of the player.
@export var holsterRotations : Vector2 ## Same as position but for RCS rotations
@export var weaponDragTiltCurve : Curve ## rotation of the weapon proportional to the angular momentum
@export var maxTiltMomentum : float
@export var tiltMultiplier : float

@export_group("Resources")
@export var weaponStrikeObject : Area2D ## melee collider box that detects hits with enemies 
@export var weaponAnimAnchor : Node2D ## object that handles the animations of the weapon (the "anchor" for the animations)


var angularMomentum : float = 0.0
var swinging : bool = false 
var selected : bool = false
var holsterTime : float = 0.0
var swingAngle : float = 0.0
var swingHolsterTime : float = 0.0

var player : Node2D

var collisionExcludeFrames : int = 0

func _ready():
	player = get_parent().get_parent().parentPlayer
	Select()
	#AnimationEvents(0)

func _physics_process(delta):
	if selected:
		InputEvents(delta)
		#AnimationEvents(delta)

func InputEvents(delta):
	if Input.is_action_pressed("Primary"):
		if Input.is_action_just_pressed("Primary"):
			StartSwing(delta)
		elif swinging:
			Swing(delta)
	elif swinging:
		StopSwing()

func AnimationEvents(delta):
	if swinging:
		holsterTime += delta / unholsterSpeed
	else:
		holsterTime -= delta / unholsterSpeed
	holsterTime = clampf(holsterTime, 0, 1)
	var weaponTilt = weaponDragTiltCurve.sample(angularMomentum / maxTiltMomentum)
	var holsterPosition = lerp(holsterPositions.x, holsterPositions.y, holsterCurve.sample(holsterTime))
	var holsterRotation = lerp(holsterRotations.x, holsterRotations.y, holsterCurve.sample(holsterTime))
	weaponAnimAnchor.position.x = holsterPosition
	weaponAnimAnchor.rotation = holsterRotation + weaponTilt

func Swing(delta): 
	var cursor = get_global_mouse_position()
	var swingPullAngle = (global_position + global_transform.x - player.global_position).angle_to(cursor - player.global_position) 
	var swingPullForce
	if swingPullAngle >= 0:
		swingPullForce = swingForceCurve.sample(abs(swingPullAngle) / (swingForceMaxAngle * PI))
	else:
		swingPullForce = -swingForceCurve.sample(abs(swingPullAngle) / (swingForceMaxAngle * PI))
	var weaponDifRot = (global_rotation - player.global_rotation) * 4
	angularMomentum -= angularMomentum * swingDrag * delta
	angularMomentum -= (1 / ((weaponDifRot * weaponDifRot) + 1)) * stopForce * delta * angularMomentum
	angularMomentum += (swingPullForce * delta) / weight
	angularMomentum = clampf(angularMomentum, -maximumMomentum, maximumMomentum)
	swingAngle += angularMomentum
	global_rotation = swingAngle
	Collide(delta)

func StartSwing(delta):
	swinging = true 
	swingAngle = global_rotation
	Swing(delta)

func StopSwing():
	rotation = 0.0
	angularMomentum = 0.0
	swinging = false

func Select():
	selected = true
	visible = true

func Deselect():
	swinging = false
	swingHolsterTime = 0.0
	angularMomentum = 0.0
	selected = false
	visible = false

func Collide(delta):
	collisionExcludeFrames -= 1
	collisionExcludeFrames = clampi(collisionExcludeFrames, 0, 10)
	if collisionExcludeFrames > 0:
		return null
	var hit = weaponStrikeObject.get_overlapping_bodies()
	if hit:
		collisionExcludeFrames = 10
		angularMomentum *= -collisionPadding
	for i in hit.size():
		var hitObject = hit[i]
		var hitObjScript = hit.get_typed_script()
		if hitObject.name == "Enemy":
			hitObject.TakeDamage(baseDamage + (angularMomentum * velocityDamageMulti * 100))
