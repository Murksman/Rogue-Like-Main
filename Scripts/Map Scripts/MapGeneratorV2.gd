extends Node2D
class_name MapGenerater

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
		ValidateRooms()
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
	rng.randomize()
	rooms = []
	currentRoomNumber = 0
	
	# Removing items on the board
	var tempObjectCount = $".".get_child_count()
	for n in tempObjectCount:
		$".".get_child(tempObjectCount - 1 - n).queue_free()
	
	var tempOccluderCount = occluderAnchor.get_child_count()
	for n in tempOccluderCount:
		occluderAnchor.get_child(tempOccluderCount - 1 - n).queue_free()
	
	# initializing the 2d tilemap for the level
	mapSizeLength = rng.randi_range(mapSizeRandLength.x, mapSizeRandLength.y) + 2 * mapSizePadding
	mapSizeWidth = rng.randi_range(mapSizeRandWidth.x, mapSizeRandWidth.y) + 2 * mapSizePadding
	
	roomScaleObject.scale = Vector2(mapSizeLength, mapSizeWidth)
	
	levelTileMap = []
	wallTileMap = []
	perimeterTiles = []
	
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
	newRoom.roomCoordX = mapSizePadding + 1
	newRoom.roomCoordY = mapSizePadding + 1
	#newRoom.roomCoordX = rng.randi_range(mapSizePadding, mapSizeLength - mapSizePadding - 1)
	#newRoom.roomCoordY = rng.randi_range(mapSizePadding, mapSizeWidth - mapSizePadding - 1)
	newRoom.arrayPosition = 0
	#for i in rng.randi_range(fluxRoomRange.x, fluxRoomRange.y):
	#	var newRoom = RoomGenData.new()
	#	rooms.append(newRoom)
	#	newRoom.roomCoordX = rng.randi_range(mapSizePadding, mapSizeLength - mapSizePadding - 1)
	#	newRoom.roomCoordY = rng.randi_range(mapSizePadding, mapSizeWidth - mapSizePadding - 1)
	#	newRoom.arrayPosition = i


func ValidateRooms():
	var tempRooms : Array[RoomGenData] = []
	var mergeArray : Array[bool] = []
	mergeArray.resize(rooms.size())
	mergeArray.fill(false)
	tempRooms.resize(rooms.size())
	for i in rooms.size():
		var mergingRoom = rooms[i]
		if !mergeArray[i]:
			tempRooms[i] = mergingRoom
			mergingRoom.upperBound = clamp(mergingRoom.roomCoordY - rng.randi_range(roomSizeRange.x, roomSizeRange.y), 0, mapSizeWidth)
			mergingRoom.lowerBound = clamp(mergingRoom.roomCoordY + rng.randi_range(roomSizeRange.x, roomSizeRange.y), 0, mapSizeWidth)
			mergingRoom.leftBound = clamp(mergingRoom.roomCoordX - rng.randi_range(roomSizeRange.x, roomSizeRange.y), 0, mapSizeLength)
			mergingRoom.rightBound = clamp(mergingRoom.roomCoordX + rng.randi_range(roomSizeRange.x, roomSizeRange.y), 0, mapSizeLength)
			for n in rooms.size():
				var mergeSecondary = rooms[n]
				if n != mergingRoom.arrayPosition && mergeSecondary.roomCoordX >= mergingRoom.leftBound && mergeSecondary.roomCoordX <= mergingRoom.rightBound && mergeSecondary.roomCoordY >= mergingRoom.upperBound && mergeSecondary.roomCoordY <= mergingRoom.lowerBound:
					mergeArray[n] = true
	
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
		var generatableRoom : RoomGenData = rooms[i]
		var roomLength = generatableRoom.rightBound - generatableRoom.leftBound + 1
		var roomWidth = generatableRoom.lowerBound - generatableRoom.upperBound + 1
		for n in roomLength:
			var newRoomRow : Array[bool] = []
			var newWallRow : Array[bool] = []
			newWallRow.resize(roomWidth)
			newRoomRow.resize(roomWidth)
			newWallRow.fill(true)
			newRoomRow.fill(true)
			generatableRoom.roomTileMap.append(newRoomRow)
			generatableRoom.wallTileMap.append(newWallRow)
		# var sections = rng.randi_range(roomSectionMin, roomSectionMax)
		var marker = roomMarkerObject.instantiate()
		$".".add_child(marker)
		marker.global_position = Vector2(generatableRoom.roomCoordX, generatableRoom.roomCoordY) * 32
		#for n in sections:
		#	var sectionLength = rng.randi_range(sectionLengthWidthRange.x, clamp(sectionLengthWidthRange.y, 0, roomLength))
		#	var sectionWidth = rng.randi_range(sectionLengthWidthRange.x, clamp(sectionLengthWidthRange.y, 0, roomWidth))
		#	var sectionX = rng.randi_range(0, roomLength - sectionLength)
		#	var sectionY = rng.randi_range(0, roomWidth - sectionWidth)


# Processes the rooms dimensions into actual tiles on the tilemap
func ProcessRooms():
	for i in rooms.size():
		#var randRedShift = randf_range(0, 1)
		#var randGreenShift = randf_range(0, 1)
		#var randBlueShift = randf_range(0, 1)
		var createRoom = rooms[i]
		var roomTempLength = createRoom.rightBound - createRoom.leftBound + 1
		var roomTempWidth = createRoom.lowerBound - createRoom.upperBound + 1
		for x in roomTempLength:
			for y in roomTempWidth:
				var floorX = x + createRoom.leftBound + 1
				var floorY = y + createRoom.upperBound
				#if createRoom.roomTileMap[x][y] && levelTileMap[x + createRoom.leftBound][y + createRoom.upperBound] == 0:
				levelTileMap[floorX + createRoom.leftBound][floorY + createRoom.upperBound] = createRoom.roomNumber
				
				MakePerimeter()
				
				#if perimeterTiles[x + createRoom.leftBound][y + createRoom.upperBound]:
				if levelTileMap[x + createRoom.leftBound][y + createRoom.upperBound] > 0:
					var newFloor = floorObject.instantiate()
					$".".add_child(newFloor)
					newFloor.global_position = Vector2(floorX + 0.5, floorY + 0.5) * 32
					#if createRoom.wallTileMap.size() > 0 && !creatsdeRoom.wallTileMap[x][y]: newFloor.modulate = Color(randRedShift, randGreenShift, randBlueShift, 1)
					#else: newFloor.modulate = Color(0.1, 0.1, 0.1, 1)
	print($".".get_child_count())


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

