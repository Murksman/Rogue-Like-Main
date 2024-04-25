extends Node
class_name ProtoMapGenerator

@export_group("Map Generation")
@export var connectorLengthRange : Vector2i

@export_group("Room Placement Parameters")
@export var minRooms : int ## This is loosely defined as this only controls the initial seed placement of the rooms, more rooms are added later in processing to make them connect
@export var maxRooms : int ## The number of rooms can be much lower than this but with exponentionally decreasing probability of less rooms (technically possible to get a map with 1 room total but with a near 0 probability)

@export_group("Room Generation Parameters")
@export var roomSizeMax : int ## Defines both the vertical and horizontal maximum length away from the central room marker
@export var roomSizeMin : int ## Defines both the vertical and horizontal minimum length away from the central room marker

@export_group("Room Content Parameters")
@export var roomMarkerResource : Resource ## The resource associated with the room marker object
@export var floorResource : Resource ## The resource associated with the floor object
@export var wallResource : Resource ## The resource associated with the wall object
@export var occluderResource : Resource ## The resource associated with the wall object

var rng = RandomNumberGenerator.new()
var roomMarkerObject : Object
var floorObject : Object
var wallObject : Object
var occluderObject : Object
var rooms : Array[ProtoGenData] = []


func _ready():
	roomMarkerObject = load(str(roomMarkerResource.resource_path))
	floorObject = load(str(floorResource.resource_path))
	wallObject = load(str(wallResource.resource_path))
	occluderObject = load(str(occluderResource.resource_path))
	
	Start()

func Start():
	pass
	
