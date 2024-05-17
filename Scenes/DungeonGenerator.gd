extends Node2D
class_name DungeonGenerator

signal character_spawn

@onready var pathfinding: Pathfinding = $"PathFindingComponent"

static var tile_map: TileMap 

#@export var width: int = 100
#@export var height: int = 100
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var number_of_rooms: int = 5
var wall_cells: Array[Vector2i]
var floor_cells: Array[Vector2i]
var room_center_array: Array[Vector2i]
var first_room: bool = true
var spawn_location: Vector2

func _ready() -> void:
	tile_map = get_node("TileMap")
	randomize()
	place_walls()
	for i in number_of_rooms:
		create_room(choose_start_point())
	print(room_center_array, "center of rooms")
	_connect_room_centers()
	tile_map.set_cells_terrain_connect(0, wall_cells, 0, 0)
	tile_map.set_cells_terrain_connect(0, floor_cells, 0, 1)
	SignalBus.emit_signal("dungeon_generation_complete")

func choose_start_point() -> Vector2i:
	return Vector2i(rng.randi_range(1, Globals.ASTAR_DIMENSIONS.size.x), rng.randi_range(1, Globals.ASTAR_DIMENSIONS.size.y))

func create_room(tile_position: Vector2i) -> void:
	var min_room_width: int = 4
	var max_room_width: int = 10
	var min_room_height: int = 4
	var max_room_height: int = 10

	var room_width: int = rng.randi_range(min_room_width, max_room_width)
	var room_height: int = rng.randi_range(min_room_height, max_room_height)
	
	if _validate_room_placement(tile_position, room_width, room_height):
		for w in room_width:
			for h in room_height:
				if first_room:
					spawn_location = Vector2(w + tile_position.x * 16 + 8, h + tile_position.y * 16 + 8)
					first_room = false
					emit_signal("character_spawn", spawn_location)
				floor_cells.append(Vector2i(w + tile_position.x, h + tile_position.y))
				tile_map.set_cell(0, Vector2i(w + tile_position.x, h + tile_position.y), 1, Vector2i(1,0))
				wall_cells.erase(Vector2i(w + tile_position.x, h + tile_position.y))
		var center_of_room: Vector2i = Vector2i(floor(tile_position.x + room_width / 2), floor(tile_position.y + room_height / 2))
		room_center_array.append(center_of_room)


func _connect_room_centers() -> void:
	var corridor_start: Vector2i
	var corridor_end: Vector2i
	for room in room_center_array:
		if room_center_array.size() > 1:
			corridor_start = room_center_array.pop_front()
			corridor_end = room_center_array.front()
		var corridor_path: Array[Vector2i] = pathfinding.get_move_path(corridor_start, corridor_end)
		for c in corridor_path:
			floor_cells.append(Vector2i(c.x, c.y))
			tile_map.set_cell(0, Vector2i(c.x, c.y), 1, Vector2i(1,0))
			wall_cells.erase(Vector2i(c.x, c.y))

func _validate_room_placement(starting_tile: Vector2i, room_w: int, room_h: int) -> bool:
	if starting_tile.x + room_w >= Globals.ASTAR_DIMENSIONS.size.x or starting_tile.y + room_h >= Globals.ASTAR_DIMENSIONS.size.y:
		return false
	
	if tile_map.get_cell_tile_data(0, Vector2i(starting_tile.x, starting_tile.y)).get_custom_data("wall") == true \
	and tile_map.get_cell_tile_data(0, Vector2i(starting_tile.x + room_w, starting_tile.y)).get_custom_data("wall") == true \
	and tile_map.get_cell_tile_data(0, Vector2i(starting_tile.x, starting_tile.y + room_h)).get_custom_data("wall") == true \
	and tile_map.get_cell_tile_data(0, Vector2i(starting_tile.x + room_w, starting_tile.y + room_h)).get_custom_data("wall") == true:
		return true
	return false

func place_walls() -> void:
	for x in range(Globals.ASTAR_DIMENSIONS.size.x):
		for y in range(Globals.ASTAR_DIMENSIONS.size.y):
			wall_cells.append(Vector2i(x,y))
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))


