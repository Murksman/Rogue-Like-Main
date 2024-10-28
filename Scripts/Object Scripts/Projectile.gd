extends Sprite2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO
var velocity : float = 0.0
var damage : float = 0.0
var maxTime : float = 1.0
var numberOfBounces : int = 0

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D
var stopped : bool = false
var bounce_off_targets : bool = true
var target_penetration : int = 0
var penetration_damage_loss : bool = true

var time : float = 0.0
var remainingDist : float = 0.0
var radius : float = 4

var hitRID : Array[RID] = []

@onready var parent_container = $".."

# Called when the node enters the scene tree for thasae first time.
func _ready():
	pass # Replace with function body.

func addStats(newVelocity, newDirection, newDamage, newMaxTime, bounces):
	direction = newDirection
	velocity = newVelocity
	damage = newDamage
	maxTime = newMaxTime
	numberOfBounces = bounces

func _physics_process(delta):
	time += delta
	
	if time >= maxTime:
		self.queue_free()
	
	if !stopped:
		spaceState = get_world_2d().direct_space_state
		ProjectilePhysics(delta)


func ProjectilePhysics(delta):
	remainingDist = velocity * delta * 60
	
	for i in 10:
		var traveled = ProjectileRaycast()
		if traveled:
			break


func ProjectileRaycast() -> bool:
	query = PhysicsRayQueryParameters2D.create(global_position + (direction * radius), global_position + (direction * (velocity + radius)), 7, hitRID)
	
	var hit = spaceState.intersect_ray(query)
	var bouncable = false
	
	if !hit:
		global_position += remainingDist * direction
		remainingDist = 0
		return true
	
	var hitCollider = hit.collider
	
	if hitCollider.get_collision_layer_value(4):
		bouncable = true
		
		var target_damage_taken = hitCollider.get_parent().TakeDamage(damage)
		
		if numberOfBounces <= 0 && penetration_damage_loss && target_damage_taken && target_damage_taken > 0: 
			damage -= target_damage_taken
		
		hitRID = []
		
	elif hitCollider.get_collision_layer_value(3):
		bouncable = bounce_off_targets
		
		if hitCollider.get_parent().currentHealth > 0:
			var target_damage_taken = hitCollider.get_parent().TakeDamage(damage)
			
			if bouncable && numberOfBounces > 0 && penetration_damage_loss && target_damage_taken && target_damage_taken > 0: 
				damage -= target_damage_taken
			
			hitRID.append(hitCollider.get_rid())
	
	if damage <= 0:
		global_position = hit.position
		stopped = true
		return true
	
	if !bouncable: return true
	
	if numberOfBounces > 0:
		numberOfBounces -= 1
		var hitDist = (hit.position - (global_position + (direction * radius))).length()
		var hitAngle = (-direction).angle_to(hit.normal)
		direction = (direction + (2 * cos(hitAngle) * hit.normal)).normalized()
		look_at(direction + global_position)
		global_position += hitDist * direction
		remainingDist -= hitDist
		
		return false
	else:
		global_position = hit.position
		stopped = true
		
		return true


