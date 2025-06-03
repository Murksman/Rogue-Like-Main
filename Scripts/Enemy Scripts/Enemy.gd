extends CharacterBody2D

@export_group("Enemy Settings")
@export var settings : EnemySettings

@export_group("Enemy Resources")
@export var agent : NavigationAgent2D

@onready var currentHealth : float = settings.baseHealth

var aggression : float = 0.0 
var hit_charge : float = 0.0 

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D

func TakeDamage(inDamage):
	currentHealth -= inDamage
	if currentHealth <= 0: queue_free()

func _physics_process(delta):
	var player = get_parent().player
	spaceState = get_world_2d().direct_space_state
	query = PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1)
	var hit = spaceState.intersect_ray(query)
	if (hit && hit.collider.get_collision_layer_value(6)) || (player.global_position - global_position).length() <= settings.autoAlertRadius:
		aggression = settings.aggroLevel
	
	if aggression > 0.0:
		aggression -= delta
		aggression = max(aggression, 0.0)
		
		look_at(player.position)
		agent.target_position = player.global_position
		var targetDirection = (agent.get_next_path_position() - global_position).normalized()
		velocity += targetDirection * settings.accel * delta
		velocity -= velocity * settings.drag * delta
		
		if (player.global_position - global_position).length() < settings.hitRange && player.alive:
			hit_charge += delta
		else:
			hit_charge -= delta
		
		hit_charge = max(hit_charge, 0.0)
		move_and_slide()
	
	if hit_charge >= settings.hitInterval:
		hit_charge -= settings.hitInterval
		player.TakeDamage(settings.damage)
	
	entity_layer_sprite.global_position = global_position
