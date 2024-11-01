extends CharacterBody2D

@export_category("Controls")
@export var acceleration : float
@export var drag : float
@export var staticDrag : float
@export var zoomMinMax : Vector2
@export var zoomSmoothRate : float

@export_category("Resources")
@export var inventory_elements : Control
@export var backpack_inventory : Inventory
@export var loadout_inventory : WeaponLoadout
@export var world_obj_inventory : GridContainer
@export var obj_inventory_container : Control
@export var weapon_holder : Node2D
@export var usable_entity_area : Area2D
@export var usable_area : Area2D
@export var projectileContainer : Node2D

var moveDirection : Vector2 = Vector2.ZERO
var velocityNorm : Vector2 = Vector2.ZERO
var camera : Camera2D

var alive : bool = true
var ui_open : bool = false
var health : float = 100.0

func _ready():
	camera = $Camera2D


func _physics_process(delta):
	if alive:
		Movement(delta)


func _input(event):
	if event.is_action_pressed("Save"):
		SceneLoadingContainer.SaveGame()
	
	if event.is_action_pressed("Use Action"):
		UseAction()
	
	if event.is_action_pressed("Inventory"):
		InventoryOpen()



func Movement(delta):
	if !ui_open: moveDirection = Input.get_vector("Left", "Right", "Up", "Down")
	else: moveDirection = Vector2.ZERO
	
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
	
	usable_area.global_position = global_position
	usable_entity_area.global_position = global_position

func InventoryOpen():
	if ui_open:
		obj_inventory_container.visible = false
		world_obj_inventory.CloseInventory()
	ui_open = !ui_open
	inventory_elements.visible = ui_open

func UseAction():
	if ui_open: 
		InventoryOpen()
		return
	
	var action_items = usable_area.get_overlapping_areas()
	action_items.append_array(usable_entity_area.get_overlapping_areas())
	
	if action_items.size() == 0: return
	
	var closest_object : ActionableObject
	var closest_point : int
	for item in action_items:
		if not item is ActionableObject: continue
		if closest_object == null:
			closest_object = item
			closest_point = (item.position - position).length()
			continue
		if (item.position - position).length() > closest_point:
			closest_point = (item.position - position).length()
	
	if closest_object is Chest: 
		world_obj_inventory.OpenInventory(closest_object)
		InventoryOpen()
	elif closest_object is LevelExit: SceneLoadingContainer.ExitLevel()
	else: return

func TakeDamage(damage):
	health -= damage
	if health <= 0:
		alive = false
