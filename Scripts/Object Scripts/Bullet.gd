extends Sprite2D

var direction : Vector2 = Vector2.ZERO
var velocity : float = 0.0
var damage : float = 0.0
var maxTime : float = 1.0
var numberOfBounces : int = 0

var spaceState : PhysicsDirectSpaceState2D
var query : PhysicsRayQueryParameters2D
var stopped : bool = false

var time : float = 0.0
var remainingDist : float = 0.0
var radius : float = 4

var hitRID : RID

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
	spaceState = get_world_2d().direct_space_state
	time += delta
	
	if time >= maxTime:
		self.queue_free()
	
	if !stopped:
		ProjectilePhysics(delta)


func ProjectilePhysics(delta):
	remainingDist = velocity * delta * 60
	# var iterations : int = 0 >> iterations are not currently used but are useful for bugtesting
	for i in 10:
		# iterations += 1
		var traveled = ProjectileRaycast()
		if traveled:
			break



func ProjectileRaycast():
	query = PhysicsRayQueryParameters2D.create(global_position + (direction * radius), global_position + (direction * (velocity + radius)), 7, [hitRID])
	var hit = spaceState.intersect_ray(query)
	var hitDead = false
	if hit:
		var hitCollider = hit.collider
		if hitCollider.get_class() == "TileMap":
			print(parent_container.tileMapCells)
			var test1 = hitCollider.get_pattern(0, [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0)]).get_size()
		elif hitCollider.get_collision_layer_value(3):
			if hitCollider.currentHealth > 0:
				hitCollider.TakeDamage(damage)
			else:
				hitDead = true
				hitRID = hitCollider.get_rid()
		if numberOfBounces > 0 && !hitDead:
			numberOfBounces -= 1
			var hitDist = (hit.position - (global_position + (direction * radius))).length()
			var hitAngle = (-direction).angle_to(hit.normal)
			direction = (direction + (2 * cos(hitAngle) * hit.normal)).normalized()
			global_position += hitDist * direction
			remainingDist -= hitDist
			return false
		elif !hitDead:
			global_position = hit.position
			stopped = true
			return true
	else:
		global_position += remainingDist * direction
		remainingDist = 0
		return true


