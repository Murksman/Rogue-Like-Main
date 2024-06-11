extends CharacterBody2D

@export_category("Controls")
@export var acceleration : float
@export var drag : float
@export var staticDrag : float
@export var zoomMinMax : Vector2
@export var zoomSmoothRate : float

@export_category("Resources")
@export var projectileContainer : Node2D

#var spaceState : PhysicsDirectSpaceState2D
#var query : PhysicsRayQueryParameters2D

var moveDirection : Vector2 = Vector2.ZERO
var velocityNorm : Vector2 = Vector2.ZERO
var camera : Camera2D

var alive : bool = true
var health : float = 100.0

func _ready():
	camera = $Camera2D


func _physics_process(delta):
	if alive:
		Movement(delta)


func Movement(delta):
	moveDirection = Input.get_vector("Left", "Right", "Up", "Down")
	velocityNorm = velocity.normalized()
	
	velocity -= velocity.length_squared() * velocityNorm * delta * drag * 0.01
	if velocity.length() < staticDrag * delta * 100:
		velocity = Vector2.ZERO
	else:
		velocity -= staticDrag * velocityNorm * delta * 100
	
	if Input.is_action_pressed("Shift"):
		velocity += moveDirection * acceleration * delta * 200
	else:
		velocity += moveDirection * acceleration * delta * 100
	move_and_slide()

func TakeDamage(damage):
	health -= damage
	if health <= 0:
		alive = false
