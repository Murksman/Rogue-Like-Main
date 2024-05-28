extends CharacterBody2D

@export_category("Controls")
@export var acceleration : float
@export var drag : float
@export var staticDrag : float
@export var zoomMinMax : Vector2
@export var zoomSmoothRate : float

@export_category("Resources")
@export var ballTest = preload("res://Prefabs/World Objects/Misc/ball_test.tscn")
@export var projectileContainer : Node2D

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D

var moveDirection : Vector2 = Vector2.ZERO
var lookDirection : Vector2 = Vector2.ZERO
var velocityNorm : Vector2 = Vector2.ZERO
var camera : Camera2D

var health : float = 50.0

func _ready():
	camera = $Camera2D


func _physics_process(delta):
	Movement(delta)
	camera.shader_orientation(lookDirection)


func Movement(delta):
	var mousePosition = get_global_mouse_position()
	lookDirection = (mousePosition - global_position).normalized()
	look_at(mousePosition)
	moveDirection = Input.get_vector("Left", "Right", "Up", "Down")
	velocityNorm = velocity.normalized()
	
	velocity -= velocity.length_squared() * velocityNorm * delta * drag * 0.01
	if velocity.length() < staticDrag * delta * 100:
		velocity = Vector2.ZERO
	else:
		velocity -= staticDrag * velocityNorm * delta * 100
	velocity += moveDirection * acceleration * delta * 100
	move_and_slide()
