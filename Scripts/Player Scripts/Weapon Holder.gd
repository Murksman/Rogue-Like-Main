extends Node2D
@export var weaponSlots : int
@export var defaultWeapon : int = 1
@export var parentPlayer : CharacterBody2D
@export var orientation : Node2D
@export var slotArray : Array[Node2D]

var activeWeapons : Array[bool] = []
var selected_index : int
var selected_weapon : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	selected_index = defaultWeapon - 1
	WeaponState()
	SelectWeapon()


func _unhandled_input(event):
	#print(selected_index, " ", selected_weapon)
	#changes the selected int depending on the input number key
	if !event.is_pressed():
		return
	if event is InputEventKey:
		var eventInt = event.as_text().to_int()
		if clamp(eventInt, 1, weaponSlots) == eventInt && eventInt != selected_index + 1:
			selected_index = eventInt - 1
			SelectWeapon()
	# increments the selected int from the mouse wheel
	elif event is InputEventMouseButton:
		var mouseWheel : int
		if event.is_action_pressed("Next Weapon"):
			mouseWheel = 1
		if event.is_action_pressed("Previous Weapon"):
			mouseWheel = -1
		selected_index = (selected_index + mouseWheel) % weaponSlots
		if selected_index < 0:
			selected_index += weaponSlots
		if mouseWheel != 0:
			SelectWeapon()

func SelectWeapon():
	var try_index = NearestWeapon(selected_index)
	if try_index == null: return
	else: selected_index = try_index
	
	for i in weaponSlots:
		var selectObject = slotArray[i].get_child(0)
		if selectObject == null: continue
		
		
		if i == selected_index:
			#print("select: ", i)
			selectObject.Select(parentPlayer, orientation)
		else:
			#print("De-select: ", i)
			selectObject.Deselect()

func NearestWeapon(index):
	for i in weaponSlots:
		var n = (i + index) % (weaponSlots)
		if activeWeapons[n]:
			return n
	return null

func AddWeapon(select_new_weapon : bool = false, new_index : int = 0):
	WeaponState()
	if select_new_weapon:
		selected_index = new_index
	
	SelectWeapon()

func RemoveWeapon(remove_index):
	WeaponState()
	if selected_index == remove_index:
		selected_index = 0
		selected_weapon = null
		SelectWeapon()

func WeaponState():
	activeWeapons = []
	activeWeapons.resize(weaponSlots)
	for i in weaponSlots:
		activeWeapons[i] = false
		if get_child(i).get_child_count() > 0:
			activeWeapons[i] = true

func WipeWeapons():
	for slot in slotArray:
		for t_weapon in slot.get_children():
			t_weapon.queue_free()
