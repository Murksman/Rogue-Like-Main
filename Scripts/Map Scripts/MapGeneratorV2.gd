extends Node2D
#class_name MapGenerater

@export_group("General")
@export var occluderAnchor : Node2D

@export_group("Map Definitions")
@export var mapSizeRandWidth : Vector2i ## Relative to y coordinate, Width is defined as distance from top to bottom
@export var mapSizeRandLength : Vector2i ## Relative to x coordinate, Length is defined as distance from left to right
@export var mapSizePadding : int ## Defines the amount of added space on the outer edge that is used for any overflowing objects in the map. Notably ScatterRooms cannot use this extra padding but most steps can.

@export_group("Room Placement Parameters")
@export var fluxRoomRange : Vector2i ## This defines the the min to max rooms generated before the room growth process.

@export_group("Room Generation Parameters")
@export var roomSizeRange : Vector2i ## This defines the size range 
# @export var sectionLengthWidthRange : Vector2i ## Sets the maximum length of the side lengths for a room section to generate, this cannot be higher than the inherited size of the room bounds or lower than the minimum

@export_group("Room Content Parameters")
@export var roomMarkerResource : Resource ## The resource associated with the room marker object
@export var floorResource : Resource ## The resource associated with the floor object
@export var wallResource : Resource ## The resource associated with the wall object
@export var occluderResource : Resource ## The resource associated with the wall object
@export var roomScaleObject : Node2D

var mapSizeLength : int
var mapSizeWidth : int
var currentRoomNumber : int = 0

var rng = RandomNumberGenerator.new()
var roomMarkerObject : Object
var floorObject : Object
var wallObject : Object
var occluderObject : Object
var rooms : Array[RoomGenData] = []
var perimeterTiles : Array[Array] = []
var levelTileMap : Array[Array] = []
var wallTileMap : Array[Array] = []

var GameGenIterations : int = 1
var gameRunning : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	roomMarkerObject = load(str(roomMarkerResource.resource_path))
	floorObject = load(str(floorResource.resource_path))
	wallObject = load(str(wallResource.resource_path))
	occluderObject = load(str(occluderResource.resource_path))
	
	Start()

func _input(event):
	if event.is_action_pressed("Enter") && !gameRunning:
		Start()

func Start():
	gameRunning = true
	var performanceTime = 0
	for i in GameGenIterations:
		var performanceTimeTemp = Time.get_ticks_msec()
		Initialization()
		ScatterRooms()
		#ValidateRooms()
		GenerateRooms()
		ProcessRooms()
		GenerateWalls()
		for n in levelTileMap.size():
			print(levelTileMap[n])
		print("time: ", Time.get_ticks_msec() - performanceTimeTemp, " ms")
		performanceTime += Time.get_ticks_msec() - performanceTimeTemp
		await get_tree().create_timer(0.01).timeout
	gameRunning = false
	print("Total Average Time Taken:  ---  ", performanceTime / GameGenIterations, " ms  ---  (milliSeconds)")

func Initialization():
	# Initialization function cleans up objects from previous runs and instantiates arrays.
	
	rng.randomize()
	rooms = []
	currentRoomNumber = 0
	
	# Removing items on the board
	for n in $".".get_child_count():
		$".".get_child($".".get_child_count() - 1 - n).queue_free()
	
	
	for n in occluderAnchor.get_child_count():
		occluderAnchor.get_child(occluderAnchor.get_child_count() - 1 - n).queue_free()
	
	# initializing the 2d tilemap for the level
	mapSizeLength = rng.randi_range(mapSizeRandLength.x, mapSizeRandLength.y) + 2 * mapSizePadding
	mapSizeWidth = rng.randi_range(mapSizeRandWidth.x, mapSizeRandWidth.y) + 2 * mapSizePadding
	
	roomScaleObject.scale = Vector2(mapSizeLength, mapSizeWidth)
	
	perimeterTiles = []
	levelTileMap = []
	wallTileMap = []
	
	for i in mapSizeLength: 
		var newLevelRow : Array[int] = []
		newLevelRow.resize(mapSizeWidth)
		newLevelRow.fill(0)
		levelTileMap.append(newLevelRow)
	for i in mapSizeLength: 
		var newPerimeterRow : Array[bool] = []
		newPerimeterRow.resize(mapSizeWidth)
		newPerimeterRow.fill(false)
		perimeterTiles.append(newPerimeterRow)
	for i in mapSizeLength + 1: 
		var newWallRow : Array[Object] = []
		newWallRow.resize(mapSizeWidth + 1)
		newWallRow.fill(null)
		wallTileMap.append(newWallRow)


func ScatterRooms():
	var newRoom = RoomGenData.new()
	
	rooms.append(newRoom)
	newRoom.arrayPosition = 0
	newRoom.roomNumber = 1
	newRoom.startBound.x = randi_range(mapSizePadding, mapSizeLength - mapSizePadding - roomSizeRange.x)
	newRoom.startBound.y = randi_range(mapSizePadding, mapSizeWidth - mapSizePadding - roomSizeRange.x)
	newRoom.endBound.x = randi_range(newRoom.startBound.x + roomSizeRange.x - 1, clamp(newRoom.startBound.x + roomSizeRange.y - 1, 0, mapSizeLength - mapSizePadding - 1))
	newRoom.endBound.y = randi_range(newRoom.startBound.y + roomSizeRange.x - 1, clamp(newRoom.startBound.y + roomSizeRange.y - 1, 0, mapSizeWidth - mapSizePadding - 1))
	newRoom.roomSize.x = newRoom.endBound.x - newRoom.startBound.x + 1
	newRoom.roomSize.y = newRoom.endBound.y - newRoom.startBound.y + 1
	print(newRoom.endBound)

func ValidateRooms():
	var tempRooms : Array[RoomGenData] = []
	var mergeArray : Array[bool] = []
	mergeArray.resize(rooms.size())
	mergeArray.fill(false)
	tempRooms.resize(rooms.size())
	for tRoom in rooms:
		for cRoom in rooms:
			return
	
	# delete merged rooms
	for i in rooms.size():
		if mergeArray[i]:
			tempRooms[i] = null
	
	rooms = []
	for i in tempRooms.size():
		var tempRoomCheck = tempRooms[i]
		if tempRoomCheck != null:
			currentRoomNumber += 1
			tempRoomCheck.roomNumber = currentRoomNumber
			rooms.append(tempRoomCheck)


# Generates the sections in a room to generate its shape
func GenerateRooms():
	for i in rooms.size():
		var genRoom : RoomGenData = rooms[i]
		for n in genRoom.roomSize.x:
			var newRoomRow : Array[bool] = []
			newRoomRow.resize(genRoom.roomSize.y)
			newRoomRow.fill(true)
			genRoom.roomTileMap.append(newRoomRow)


func ProcessRooms():
	for i in rooms.size():
		var cRoom = rooms[i]
		for x in cRoom.roomSize.x:
			for y in cRoom.roomSize.y:
				var floorX = x + cRoom.startBound.x
				var floorY = y + cRoom.startBound.y
				
				levelTileMap[floorX][floorY] = cRoom.roomNumber
				
				#MakePerimeter()
				
				if levelTileMap[x + cRoom.startBound.x][y + cRoom.startBound.y] > 0:
					var newFloor = floorObject.instantiate()
					$".".add_child(newFloor)
					newFloor.global_position = Vector2(floorX + 0.5, floorY + 0.5) * 32


func GenerateWalls():
	for x in mapSizeLength:
		for y in mapSizeWidth:
			if levelTileMap[x][y] > 0:
				if levelTileMap[x-1][y] == 0: wallTileMap[x][y] = SpawnWall(false, Vector2(x,y + 0.5) * 32)
				if levelTileMap[x][y-1] == 0: wallTileMap[x][y] = SpawnWall(true, Vector2(x + 0.5,y) * 32)
			else:
				if levelTileMap[x-1][y] > 0: wallTileMap[x][y] = SpawnWall(false, Vector2(x,y + 0.5) * 32)
				if levelTileMap[x][y-1] > 0: wallTileMap[x][y] = SpawnWall(true, Vector2(x + 0.5,y) * 32)


func SpawnWall(vertical, wallPosition):
	var newWall = wallObject.instantiate()
	var newOccluder = occluderObject.instantiate()
	$".".add_child(newWall)
	occluderAnchor.add_child(newOccluder)
	newWall.position = wallPosition
	newOccluder.position = wallPosition
	if vertical: 
		newWall.rotation = PI / 2
		newOccluder.rotation = PI / 2
	return newWall



func MakePerimeter():
	for x in levelTileMap.size():
		for y in levelTileMap[0].size():
			x = clamp(x, 1, levelTileMap.size() - 2)
			y = clamp(y, 1, levelTileMap[0].size() - 2)
			if levelTileMap[x][y] == 0 && (levelTileMap[x-1][y] > 0 || levelTileMap[x][y-1] > 0 || levelTileMap[x+1][y] > 0 || levelTileMap[x][y+1]):
				perimeterTiles[x][y] = true

