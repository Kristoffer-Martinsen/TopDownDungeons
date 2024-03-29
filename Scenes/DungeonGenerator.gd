extends Node2D

@onready var tile_map: TileMap = $"TileMap"
@export var width: int = 100
@export var height: int = 100
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var wall_cells: Array[Vector2i]
var floor_cells: Array[Vector2i]
var room_center_array: Array[Vector2i]


func _ready() -> void:
	Pathfinding.set_tile_map(tile_map)
	randomize()
	place_walls()
	for i in 50:
		create_room(choose_start_point())
	_connect_room_centers()
	tile_map.set_cells_terrain_connect(0, wall_cells, 0, 0)
	tile_map.set_cells_terrain_connect(0, floor_cells, 0, 1)

func choose_start_point() -> Vector2i:
	return Vector2i(rng.randi_range(1, width), rng.randi_range(1, height))

func create_room(tile_position: Vector2i) -> void:
	var min_room_width: int = 4
	var max_room_width: int = 10
	var min_room_height: int = 4
	var max_room_height: int = 10

	var room_width: int = rng.randi_range(min_room_width, max_room_width)
	var room_height: int = rng.randi_range(min_room_height, max_room_height)

	for w in room_width:
		for h in room_height:
			floor_cells.append(Vector2i(w + tile_position.x, h + tile_position.y))
			tile_map.set_cell(0, Vector2i(w + tile_position.x, h + tile_position.y), 1, Vector2i(1,0))
			wall_cells.erase(Vector2i(w + tile_position.x, h + tile_position.y))

	var center_of_room: Vector2i = Vector2i(floor(tile_position.x + room_width / 2), floor(tile_position.y + room_height / 2))
	pass

func _connect_room_centers() -> void:
	while room_center_array.size() > 0:
		var start_center: Vector2i = room_center_array.pop_front()
		var next_center: Vector2i = room_center_array[0]
		
	pass

func place_walls() -> void:
	for x in range(height):
		for y in range(width):
			wall_cells.append(Vector2i(x,y))
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))

