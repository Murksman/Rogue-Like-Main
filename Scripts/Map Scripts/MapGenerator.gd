extends Node2D
#class_name MapGenerater

@export_group("General")
@export var occluderAnchor : Node2D

@export_group("Map Definitions")
@export var mapSizeRandWidth : Vector2i ## Relative to y coordinate, Width is defined as distance from top to bottom
@export var mapSizeRandLength : Vector2i ## Relative to x coordinate, Length is defined as distance from left to right
@export var mapSizePadding : int ## Defines the amount of added space on the outer edge that is used for any overflowing objects in the map. Notably ScatterRooms cannot use this extra padding but most steps can.

@export_group("Room Placement Parameters")
@export var roomDistPadding : int ## defines the minimum padded distamce between rooms when validating rooms. Useful for generalizing the "density" of rooms throughout the level
@export var minRooms : int ## This is loosely defined as this only controls the initial seed placement of the rooms, more rooms are added later in processing to make them connect
@export var maxRooms : int ## The number of rooms can be much lower than this but with exponentionally decreasing probability of less rooms (technically possible to get a map with 1 room total but with a near 0 probability)

@export_group("Room Generation Parameters")
@export var roomSizeMax : int ## Defines both the vertical and horizontal maximum length away from the central room marker
@export var roomSizeMin : int ## Defines both the vertical and horizontal minimum length away from the central room marker
@export var roomSectionMin : int ## Sets the Minimum amount of Sections in a room to generate
@export var roomSectionMax : int ## Sets the Maximum amount of Sections in a room to generate
# ***deprecated*** @export var sectionSideMinLength : int ## Sets the minimum length of the side lengths for a room section to generate, this cannot be higher than the inherited size of the room bounds or higher than the maximum
@export var sectionLengthWidthRange : Vector2i ## Sets the maximum length of the side lengths for a room section to generate, this cannot be higher than the inherited size of the room bounds or lower than the minimum

@export_group("Room Connection Parameters")
@export var randomConnectors : Vector2i

@export_group("Room Content Parameters")
@export var roomMarkerResource : Resource ## The resource associated with the room marker object
@export var floorResource : Resource ## The resource associated with the floor object
@export var wallResource : Resource ## The resource associated with the wall object
@export var occluderResource : Resource ## The resource associated with the wall object

var mapSizeLength : int
var mapSizeWidth : int
var currentRoomNumber : int = 0

var rng = RandomNumberGenerator.new()
var roomMarkerObject : Object
var floorObject : Object
var wallObject : Object
var occluderObject : Object
var rooms : Array[RoomGenData] = []
var levelTileMap : Array[Array] = []
var wallTileMap : Array[Array] = []

var connectorPositions : Array[Vector2i]
var connectorOrientations : Array[int]
var connectorRoomIndex : Array[int]

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
		GenerateConnectors()
		ProcessRooms()
		GenerateWalls()
		print("time: ", Time.get_ticks_msec() - performanceTimeTemp, " ms")
		performanceTime += Time.get_ticks_msec() - performanceTimeTemp
		await get_tree().create_timer(0.01).timeout
	gameRunning = false
	print("Total Average Time Taken:  ---  ", performanceTime / GameGenIterations, " ms  ---  (milliSeconds)")

func Initialization():
	rng.randomize()
	rooms = []
	connectorPositions = []
	connectorRoomIndex = []
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
	levelTileMap = []
	wallTileMap = []
	
	for i in mapSizeLength: 
		var newLevelRow : Array[int] = []
		newLevelRow.resize(mapSizeWidth)
		newLevelRow.fill(0)
		levelTileMap.append(newLevelRow)
	for i in mapSizeLength + 1: 
		var newWallRow : Array[Object] = []
		newWallRow.resize(mapSizeWidth + 1)
		newWallRow.fill(null)
		wallTileMap.append(newWallRow)

func ScatterRooms():
	for i in rng.randi_range(minRooms, maxRooms):
		var newRoom = RoomGenData.new()
		rooms.append(newRoom)
		newRoom.roomCoordX = rng.randi_range(mapSizePadding, mapSizeLength - mapSizePadding - 1)
		newRoom.roomCoordY = rng.randi_range(mapSizePadding, mapSizeWidth - mapSizePadding - 1)
		newRoom.arrayPosition = i

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
			mergingRoom.upperBound = clamp(mergingRoom.roomCoordY - rng.randi_range(roomSizeMin, roomSizeMax), 0, mapSizeWidth - 1)
			mergingRoom.lowerBound = clamp(mergingRoom.roomCoordY + rng.randi_range(roomSizeMin, roomSizeMax), 0, mapSizeWidth - 1)
			mergingRoom.leftBound = clamp(mergingRoom.roomCoordX - rng.randi_range(roomSizeMin, roomSizeMax), 0, mapSizeLength - 1)
			mergingRoom.rightBound = clamp(mergingRoom.roomCoordX + rng.randi_range(roomSizeMin, roomSizeMax), 0, mapSizeLength - 1)
			for n in rooms.size():
				var mergeSecondary = rooms[n]
				if n != mergingRoom.arrayPosition && mergeSecondary.roomCoordX + roomDistPadding >= mergingRoom.leftBound && mergeSecondary.roomCoordX - roomDistPadding <= mergingRoom.rightBound && mergeSecondary.roomCoordY + roomDistPadding >= mergingRoom.upperBound && mergeSecondary.roomCoordY - roomDistPadding <= mergingRoom.lowerBound:
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
			newWallRow.fill(false)
			newRoomRow.fill(false)
			generatableRoom.roomTileMap.append(newRoomRow)
			generatableRoom.wallTileMap.append(newWallRow)
		var sections = rng.randi_range(roomSectionMin, roomSectionMax)
		var marker = roomMarkerObject.instantiate()
		$".".add_child(marker)
		marker.global_position = Vector2(generatableRoom.roomCoordX, generatableRoom.roomCoordY) * 32
		for n in sections:
			var sectionLength = rng.randi_range(sectionLengthWidthRange.x, clamp(sectionLengthWidthRange.y, 0, roomLength))
			var sectionWidth = rng.randi_range(sectionLengthWidthRange.x, clamp(sectionLengthWidthRange.y, 0, roomWidth))
			var sectionX = rng.randi_range(0, roomLength - sectionLength)
			var sectionY = rng.randi_range(0, roomWidth - sectionWidth)
			for x in sectionLength:
				for y in sectionWidth:
					generatableRoom.roomTileMap[x + sectionX][y + sectionY] = true
		
		CalcConnector(generatableRoom, roomLength, roomWidth)


func CalcConnector(room, length, width):
	for x in length:
		for y in width:
			if room.roomTileMap[x][y]:
				var isWall = false
				if x % (length - 1) == 0 or y % (width - 1) == 0: isWall = true
				elif !room.roomTileMap[x-1][y] or !room.roomTileMap[x+1][y] or !room.roomTileMap[x][y-1] or !room.roomTileMap[x][y+1]: isWall = true
				room.wallTileMap[x][y] = isWall
				if isWall: room.wallTiles.append(Vector2i(x,y) + Vector2i(room.leftBound, room.upperBound))
	for i in randi_range(randomConnectors.x, randomConnectors.y):
		var randConnectorTile = room.wallTiles[randi_range(0, room.wallTiles.size() - 1)]
		connectorPositions.append(randConnectorTile)
		connectorRoomIndex.append(room.roomNumber)

# Generates the connector rooms between connector tiles
func GenerateConnectors():
	for i in connectorPositions.size():
		var conMinDist : int = mapSizeLength + mapSizeWidth
		var startCon : Vector2i
		var endCon : Vector2i
		for n in connectorPositions.size():
			if connectorRoomIndex[n] != connectorRoomIndex[i]:
				var conDist = abs(connectorPositions[i].x - connectorPositions[n].x) + abs(connectorPositions[i].y - connectorPositions[n].y)
				if conMinDist == null || conDist < conMinDist: 
					startCon = connectorPositions[i]
					endCon = connectorPositions[n]
					conMinDist = conDist
		
		var conRoom = RoomGenData.new()
		var conRoomLength = abs(startCon.x - endCon.x) + 1
		var conRoomWidth = abs(startCon.y - endCon.y) + 1
		var conX = mini(startCon.x, endCon.x)
		var conY = mini(startCon.y, endCon.y)
		
		conRoom.leftBound = conX
		conRoom.rightBound = conX + conRoomLength - 1
		conRoom.upperBound = conY
		conRoom.lowerBound = conY + conRoomWidth - 1
		
		var conRow : Array[bool] = []
		var conTileMap : Array[Array] = []
		conRow.resize(conRoomWidth)
		conRow.fill(true)
		conTileMap.resize(conRoomLength)
		for k in conRoomLength:
			conTileMap[k] = conRow
		
		currentRoomNumber += 1
		conRoom.roomTileMap = conTileMap
		conRoom.roomNumber = currentRoomNumber
		rooms.append(conRoom)


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
				if createRoom.roomTileMap[x][y] && levelTileMap[x + createRoom.leftBound][y + createRoom.upperBound] == 0:
					var newFloor = floorObject.instantiate()
					var floorX = x + createRoom.leftBound
					var floorY = y + createRoom.upperBound
					$".".add_child(newFloor)
					newFloor.global_position = Vector2(floorX, floorY) * 32
					var tempNumber : int = createRoom.roomNumber
					levelTileMap[floorX][floorY] = tempNumber
					#if createRoom.wallTileMap.size() > 0 && !createRoom.wallTileMap[x][y]: newFloor.modulate = Color(randRedShift, randGreenShift, randBlueShift, 1)
					#else: newFloor.modulate = Color(0.1, 0.1, 0.1, 1)


func GenerateWalls():
	for x in mapSizeLength:
		for y in mapSizeWidth:
			if levelTileMap[x][y] > 0:
				if levelTileMap[x-1][y] == 0: wallTileMap[x][y] = SpawnWall(false, Vector2(x - 0.5,y) * 32)
				if levelTileMap[x][y-1] == 0: wallTileMap[x][y] = SpawnWall(true, Vector2(x,y - 0.5) * 32)
			else:
				if levelTileMap[x-1][y] > 0: wallTileMap[x][y] = SpawnWall(false, Vector2(x - 0.5,y) * 32)
				if levelTileMap[x][y-1] > 0: wallTileMap[x][y] = SpawnWall(true, Vector2(x,y - 0.5) * 32)

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
