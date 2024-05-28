extends CharacterBody2D
class_name Enemy

@export var baseHealth : float = 100
@export var accel : float
@export var drag : float
@export var agent : NavigationAgent2D

@onready var player : CharacterBody2D = $"../..".player
@onready var currentHealth : float = baseHealth

func TakeDamage(damage):
	currentHealth -= damage
	if currentHealth <= 0:
		self.queue_free()

func _physics_process(delta):
	look_at(player.position)
	agent.target_position = player.global_position
	var targetDirection = (agent.get_next_path_position() - global_position).normalized()
	velocity += targetDirection * accel * delta
	velocity -= velocity * drag * delta
	move_and_slide()
