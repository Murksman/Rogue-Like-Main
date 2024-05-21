extends Node2D


var tileMap : TileMap
var tileMapCells : Array[Vector2i]


func _ready():
	tileMap = $"../TileMap"
	tileMapCells = tileMap.get_used_cells(0)
