extends Control

@onready var player = $"../Main Plane Controller/Main Plane/Player"
@onready var healthText : Label = $"UI Bottom Left/Health Label"
@onready var healthBar : TextureProgressBar = $"UI Bottom Left/Health Bar"
@onready var ammoBar : ProgressBar = $"UI Bottom Right/Ammo Bar"
@onready var ammoText : Label = $"UI Bottom Right/Ammo Label"

# Called when the node enters the scene tree for the first time.
func _ready():
	UpdateUI()


func UpdateUI():
	healthText.text = "Health: " + str(player.health) + " / 100"
	healthBar.value = floori(player.health)
