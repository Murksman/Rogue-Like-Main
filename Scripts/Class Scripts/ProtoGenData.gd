class_name ProtoGenData

# Position in the list array
var arrayPosition : int
# Room number for identifying different rooms
var roomNumber : int
# 2D tileMap of the room after sections have been processed
var roomTileMap : Array[Array] = []
# Array of connected rooms
var connectedRooms : Array[ProtoGenData] = []
# Array of associated connectors
var connectors : Array[Connector] = []
# List of tile positions that border the room
var wallTiles : Array[Vector2i] = []
# 2D array of wallTiles
var wallTileMap : Array[Array] = []

func _init(arrayPos, roomNum, roomSize, conRooms, cons, wTiles, wTileMap):
	for i in roomSize.x:
		var newColumn : Array[bool] = []
		newColumn.resize(roomSize.y)
		newColumn.fill(true)
		roomTileMap.append(newColumn)
	arrayPosition = arrayPos
	roomNumber = roomNum
	connectedRooms = conRooms
	connectors = cons
	wallTiles = wTiles
	wallTileMap = wTileMap
