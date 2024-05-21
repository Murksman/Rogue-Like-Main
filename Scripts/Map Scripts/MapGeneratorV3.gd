@tool
extends Node2D
class_name MapGenerator

@export var tileMap : TileMap

@export var Generate : bool:
	get: 
		return false
	set(arg):
		TestFunc()

func TestFunc():
	if tileMap != null:
		print("test")
