extends Control

@export var player : Node2D
@export var weapon_holder : Node2D

@onready var healthText : Label = $"UI Bottom Left/Health Label"
@onready var healthBar : TextureProgressBar = $"UI Bottom Left/Health Bar"
@onready var ammoBar : ProgressBar = $"UI Bottom Right/Ammo Bar"
@onready var ammoText : Label = $"UI Bottom Right/Ammo Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	UpdateUI()

func _physics_process(_delta):
	UpdateUI()

func UpdateUI():
	healthText.text = "Health: " + str(player.health) + " / 100"
	healthBar.value = floori(player.health)
	if weapon_holder.selected_weapon is Weapon:
		ammoBar.max_value = weapon_holder.selected_weapon.t_magazine_size
		ammoBar.value = weapon_holder.selected_weapon.currentMagAmmo
		ammoText.text = "Ammo: " + str(weapon_holder.selected_weapon.currentMagAmmo) + " / " + str(weapon_holder.selected_weapon.t_magazine_size)
	$"UI Bottom Right".visible = weapon_holder.selected_weapon is Weapon
	
