extends Node2D
class_name DungeonGenerator

signal character_spawn
signal room_bodies_gen_done

@onready var pathfinding: Pathfinding = $"PathFindingComponent"
@onready var room_body_scene: PackedScene = preload('res://Scenes/room_body.tscn')

static var tile_map: TileMap

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var number_of_rooms: int = 50
var wall_cells: Array[Vector2i]
var floor_cells: Array[Vector2i]
var spawn_location: Vector2
var cell_size: Vector2 = Vector2(16, 16)
var room_center_array: Array[Vector2i]
var room_body_gen_padding: int = 64
var room_dict: Dictionary = {}

func _ready() -> void:
	tile_map = get_node("TileMap")
	randomize()
	place_walls()
	for r in number_of_rooms:
		create_room_bodies(Vector2i(50, 50))
	await get_tree().create_timer(0.5).timeout
	emit_signal("room_bodies_gen_done")
	_connect_room_centers()
	tile_map.set_cells_terrain_connect(0, wall_cells, 0, 0)
	tile_map.set_cells_terrain_connect(0, floor_cells, 0, 1)
	SignalBus.emit_signal("dungeon_generation_complete")

func create_room_bodies(tile_position: Vector2i) -> void:
	var min_room_width: int = 4
	var max_room_width: int = 10
	var min_room_height: int = 4
	var max_room_height: int = 10

	var room_width: int = rng.randi_range(min_room_width, max_room_width)
	var room_height: int = rng.randi_range(min_room_height, max_room_height)
	var room_body: RigidBody2D = room_body_scene.instantiate()
	var collision_shape = room_body.get_child(0)
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(
		room_width * cell_size.x + room_body_gen_padding, 
		room_height * cell_size.y + room_body_gen_padding
		)
	get_node('Rooms').add_child(room_body)

	spawn_location = Vector2(50, 50)
	emit_signal("character_spawn", spawn_location)

func _connect_room_centers() -> void:
	var corridor_start: Vector2i
	var corridor_end: Vector2i
	#TODO create corridors based on a minimum spanning tree
	for room in room_center_array:
		if room_center_array.size() > 1:
			corridor_start = room_center_array.pop_front()
			corridor_end = room_center_array.front()
		var corridor_path: Array[Vector2i] = pathfinding.get_move_path(corridor_start, corridor_end)
		for c in corridor_path:
			floor_cells.append(Vector2i(c.x, c.y))
			tile_map.set_cell(0, Vector2i(c.x, c.y), 1, Vector2i(1,0))
			wall_cells.erase(Vector2i(c.x, c.y))

func _generate_corridor_tree() -> void:
	pass

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

func _on_room_bodies_gen_done() -> void:
	for r in get_node('Rooms').get_children():
		room_dict[tile_map.local_to_map(r.global_position)] = Vector2(r.get_node("CollisionShape2D").shape.size / cell_size)
	#TODO make ASTAR grid and tilemap use tile_map.get_ised_rect()
	#TODO remove padding from physics body when creating the rooms on the tilemap
	#HACK jesus what even is this
	for key in room_dict.keys():
		for w in room_dict[key].x:
			for h in room_dict[key].y:
				floor_cells.append(Vector2i(w + key.x, h + key.y))
				tile_map.set_cell(0, Vector2i(w + key.x, h + key.y), 1, Vector2i(1,0))
				wall_cells.erase(Vector2i(w + key.x, h + key.y))
		var center_of_room: Vector2i = Vector2i(floor(key.x + room_dict[key].x / 2), floor(key.y + room_dict[key].y / 2))
		room_center_array.append(center_of_room)
