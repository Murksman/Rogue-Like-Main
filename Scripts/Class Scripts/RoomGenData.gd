class_name RoomGenData

# Position in the list array
var arrayPosition : int
# Room Array Position
var roomCoordX : int
var roomCoordY : int
# Room Bounds
var upperBound : int
var lowerBound : int
var leftBound : int
var rightBound : int
# Room number for identifying different rooms
var roomNumber : int
# 2D tileMap of the room after sections have been processed
var roomTileMap : Array[Array] = []
# List of tile positions that border the room
var wallTiles : Array[Vector2i] = []
# 2D array of wallTiles
var wallTileMap : Array[Array] = []

