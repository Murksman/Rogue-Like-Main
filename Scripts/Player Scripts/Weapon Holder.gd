extends Node2D
@export var weaponSlots : int
@export var defaultWeapon : int = 1
@export var parentPlayer : Node2D
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
	#changes the selected int depending on the input number key
	if event is InputEventKey and event.is_pressed():
		var eventInt = event.as_text().to_int()
		if clamp(eventInt, 1, weaponSlots) == eventInt && eventInt != selected_index + 1:
			selected_index = eventInt - 1
			SelectWeapon()
	# increments the selected int from the mouse wheel
	elif event.is_pressed() && event is InputEventMouseButton:
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
	selected_index = NearestWeapon(selected_index)
	if selected_index != null:
		for i in weaponSlots:
			var selectObject = slotArray[i].get_child(0)
			if selectObject != null:
				if i == selected_index:
					selectObject.Select()
					selected_weapon = slotArray[i].get_child(0)
				else:
					selectObject.Deselect()

func NearestWeapon(index):
	for i in weaponSlots:
		var n = (i + index) % (weaponSlots)
		if activeWeapons[n]:
			return n

func AddWeapon():
	WeaponState()

func WeaponState():
	activeWeapons = []
	activeWeapons.resize(weaponSlots)
	for i in weaponSlots:
		activeWeapons[i] = false
		if get_child(i).get_child_count() > 0:
			activeWeapons[i] = true
