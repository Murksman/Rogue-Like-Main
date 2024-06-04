extends CharacterBody2D

@export var baseHealth : float = 100
@export var accel : float
@export var drag : float
@export var agent : NavigationAgent2D
@export var aggroLevel : float
@export var autoAlertRadius : float
@export var damage : float
@export var hitInterval : float
@export var hitRange : float

@onready var player : CharacterBody2D = $"../..".player
@onready var currentHealth : float = baseHealth

var aggression : float = 0.0 
var hit_charge : float = 0.0 

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
	if hit && hit.collider.get_collision_layer_value(6) || (player.global_position - global_position).length() <= autoAlertRadius:
		aggression = aggroLevel
	
	if (aggression > 0.0):
		aggression -= delta
		aggression = max(aggression, 0.0)
		
		look_at(player.position)
		agent.target_position = player.global_position
		var targetDirection = (agent.get_next_path_position() - global_position).normalized()
		velocity += targetDirection * accel * delta
		velocity -= velocity * drag * delta
		
		if (player.global_position - global_position).length() < hitRange && player.alive:
			hit_charge += delta
		else:
			hit_charge -= delta
		
		move_and_slide()
	
	if hit_charge >= hitInterval:
		hit_charge -= hitInterval
		player.TakeDamage(damage)
		print("test")
