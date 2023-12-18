extends CharacterBody2D

@export_category("Movement")
@export var acceleration : float
@export var drag : float
@export var staticDrag : float

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D

func _ready():
	pass

func _input(event):
	if event.is_action_pressed("Primary"):
		pass

func _physics_process(delta):
	Movement(delta)
	look_at(get_global_mouse_position())

func Movement(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	var velocityNorm = velocity.normalized()
	
	velocity -= velocity.length_squared() * velocityNorm * delta * drag * 0.01
	if velocity.length() < staticDrag * delta * 100:
		velocity = Vector2.ZERO
	else:
		velocity -= staticDrag * velocityNorm * delta * 100
	velocity += direction * acceleration * delta * 100
	
	print(velocity.length())
	move_and_slide()
