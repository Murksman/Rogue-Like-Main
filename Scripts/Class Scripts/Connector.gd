extends Node2D
class_name Connector

var targetRoom : ProtoGenData
var targetConnector : Connector

func _init(tRoom, tCon):
	targetRoom = tRoom
	targetConnector = tCon

func toggle_visible(is_visible):
	visible = is_visible
