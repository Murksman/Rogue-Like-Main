extends CharacterBody2D

@export var baseHealth : float = 100
@export var accel : float
@export var drag : float
@export var agent : NavigationAgent2D
@export var aggroLevel : float

@onready var player : CharacterBody2D = $"../..".player
@onready var currentHealth : float = baseHealth

var aggression : float = 0.0 

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D

func TakeDamage(damage):
	currentHealth -= damage
	if currentHealth <= 0:
		self.queue_free()

func _physics_process(delta):
	spaceState = get_world_2d().direct_space_state
	query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 33)
	var hit = spaceState.intersect_ray(query)
	if hit && hit.collider.get_collision_layer_value(6):
		aggression = aggroLevel
	
	if (aggression > 0.0):
		aggression -= delta
		aggression = max(aggression, 0.0)
		
		look_at(player.position)
		agent.target_position = player.global_position
		var targetDirection = (agent.get_next_path_position() - global_position).normalized()
		velocity += targetDirection * accel * delta
		velocity -= velocity * drag * delta
		move_and_slide()
