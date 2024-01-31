extends Node2D
@export var weaponSlots : int
@export var defaultWeapon : int = 1
@export var parentPlayer : Node2D
@export var slotArray : Array[Node2D]

var activeWeapons : Array[bool] = []
var selected : int

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = defaultWeapon - 1
	WeaponState()
	SelectWeapon()


func _unhandled_input(event):
	#changes the selected int depending on the input number key
	if event is InputEventKey and event.is_pressed():
		var eventInt = event.as_text().to_int()
		if clamp(eventInt, 1, weaponSlots) == eventInt && eventInt != selected + 1:
			selected = eventInt - 1
			SelectWeapon()
	# increments the selected int from the mouse wheel
	elif event.is_pressed() && event is InputEventMouseButton:
		var mouseWheel : int
		if event.is_action_pressed("Next Weapon"):
			mouseWheel = 1
		if event.is_action_pressed("Previous Weapon"):
			mouseWheel = -1
		selected = (selected + mouseWheel) % weaponSlots
		if selected < 0:
			selected += weaponSlots
		if mouseWheel != 0:
			SelectWeapon()

func SelectWeapon():
	selected = NearestWeapon(selected)
	if selected != null:
		for i in weaponSlots:
			var selectObject = slotArray[i].get_child(0)
			if selectObject != null:
				if i == selected:
					selectObject.Select()
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
