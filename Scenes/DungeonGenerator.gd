extends Node2D
class_name DungeonGenerator

@onready var pathfinding: Pathfinding = $"PathFindingComponent"
@onready var room_body_scene: PackedScene = preload('res://Scenes/room_body.tscn')

static var tile_map: TileMap

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var number_of_rooms: int = 40
var wall_cells: Array[Vector2i]
var floor_cells: Array[Vector2i]
var spawn_location: Vector2
var cell_size: Vector2 = Vector2(16, 16)
var room_center_array: Array[Vector2i]
var room_body_gen_padding: int = 64

func _ready() -> void:
	tile_map = get_node("TileMap")
	randomize()
	for r in number_of_rooms:
		create_room_bodies(Vector2i(50, 50))
	await get_tree().create_timer(0.3).timeout # give the physics engine time to sort out collisions
	generate_room_floors()
	_connect_room_centers()
	tile_map.set_cells_terrain_connect(0, wall_cells, 0, 0)
	tile_map.set_cells_terrain_connect(0, floor_cells, 0, 1)
	SignalBus.emit_signal("dungeon_generation_complete")

func create_room_bodies(tile_position: Vector2i) -> void:
	var min_room_width: int = 8
	var max_room_width: int = 16
	var min_room_height: int = 8
	var max_room_height: int = 16

	var room_width: int = rng.randi_range(min_room_width, max_room_width)
	var room_height: int = rng.randi_range(min_room_height, max_room_height)
	var room_body: RigidBody2D = room_body_scene.instantiate()
	var collision_shape = room_body.get_child(0)
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.size = Vector2(
		room_width * cell_size.x + room_body_gen_padding, 
		room_height * cell_size.y + room_body_gen_padding
		)
	collision_shape.position += Vector2(collision_shape.shape.size.x / 2, collision_shape.shape.size.y / 2)
	get_node('Rooms').add_child(room_body)
	room_body.global_position += Vector2(rng.randi_range(-6*16, 6*16), rng.randi_range(-6*16, 6*16))
	spawn_location = Vector2(50, 50)

func _connect_room_centers() -> void:
	#TODO create corridors based on a minimum spanning tree
	var delaunay_points = Geometry2D.triangulate_delaunay(room_center_array)
	for p in len(delaunay_points) / 3:
		var triangle_points = []
		for n in 3:
			var i = delaunay_points[(p * 3) + n]
			triangle_points.append(i)
		#connect
		for i in 2: # Tutorial said 3 but that resulted in an error :thinking:
			# TODO make a list of connections between rooms that I can make a mst from
			var room1 = room_center_array[triangle_points[i]]
			var room2 = room_center_array[triangle_points[i + 1] % 3]
			var corridor_path: Array[Vector2i] = pathfinding.get_move_path(room1, room2)
			for c in corridor_path:
				floor_cells.append(Vector2i(c.x, c.y))
				tile_map.set_cell(0, Vector2i(c.x, c.y), 1, Vector2i(1,0))
				wall_cells.erase(Vector2i(c.x, c.y))

func place_walls() -> void:
	for x in range(Globals.ASTAR_DIMENSIONS.position.x - 5, Globals.ASTAR_DIMENSIONS.position.x + Globals.ASTAR_DIMENSIONS.size.x + 5):
		for y in range(Globals.ASTAR_DIMENSIONS.position.y - 5, Globals.ASTAR_DIMENSIONS.position.y + Globals.ASTAR_DIMENSIONS.size.y + 5):
			wall_cells.append(Vector2i(x,y))
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))

func generate_room_floors() -> void:
	var room_bodies = get_node('Rooms').get_children()
	room_bodies.shuffle()
	var culled_rooms = room_bodies.slice(0, rng.randi_range(10, 15))
	for r in culled_rooms:
		var r_size = Vector2(r.get_node("CollisionShape2D").shape.size / cell_size)
		var r_pos = tile_map.local_to_map(r.global_position)
		for w in range(2, r_size.x - 2):
			for h in range(2, r_size.y - 2):
				floor_cells.append(Vector2i(w + r_pos.x, h + r_pos.y))
				tile_map.set_cell(0, Vector2i(w + r_pos.x, h + r_pos.y), 1, Vector2i(1,0))
				wall_cells.erase(Vector2i(w + r_pos.x, h + r_pos.y))
		var center_of_room: Vector2i = Vector2i(floor(r_pos.x + r_size.x / 2), floor(r_pos.y + r_size.y / 2))
		room_center_array.append(center_of_room)
		r.queue_free()
	# HACK kind of ugly to loop over again to remove the remaining physics bodies
	for rr in get_node("Rooms").get_children():
		rr.queue_free()
	Globals.ASTAR_DIMENSIONS = tile_map.get_used_rect()
	place_walls()
	SignalBus.emit_signal("dungeon_tileset_generated")

