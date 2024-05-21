class_name RoomGenData

# Position in the list array
var arrayPosition : int
# Room Dimensions
var roomSize : Vector2i
# Room Bounds
var startBound : Vector2i
var endBound : Vector2i
# Room number for identifying different rooms
var roomNumber : int
# 2D tileMap of the room after sections have been processed
var roomTileMap : Array[Array] = []
# List of tile positions that border the room
# var wallTiles : Array[Vector2i] = []
# 2D array of wallTiles
# var wallTileMap : Array[Array] = []

