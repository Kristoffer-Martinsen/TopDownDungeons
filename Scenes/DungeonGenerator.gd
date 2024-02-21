extends Node2D

@onready var tile_map: TileMap = $"TileMap"

#Get a circle
#Get random point in circle
#Create rooms with a random width and a random height
#  -> get point in tilemap
#  -> loop over rectangle based on height and width
#  -> change tile to floor
var rng = RandomNumberGenerator.new()
var cells: Array[Vector2i]


func _ready() -> void:
	randomize()
	var rr = 100
	var random_point = get_random_point_in_circle(rr)
	place_walls(rr)

	create_room(random_point)

	# random_point = get_random_point_in_circle(rr)
	tile_map.set_cells_terrain_connect(0, cells, 0, 0)

func get_random_point_in_circle(radius: int) -> Vector2:
	var theta = 2*PI*rng.randf()
	var u = rng.randf()+rng.randf()
	var r = null

	if u > 1:
		r = 2-u
	else:
		r = u
	
	return Vector2(radius*r*cos(theta), radius*r*sin(theta))

func create_room(position: Vector2) -> void:
	var tile_map_coords: Vector2i = tile_map.local_to_map(position.round())
	var min_width: int = 4
	var max_width: int = 10
	var min_height: int = 4
	var max_height: int = 10

	var width: int = rng.randi_range(min_width, max_width)
	var height: int = rng.randi_range(min_height, max_height)

	for w in width:
		for h in height:
			tile_map.set_cell(0, Vector2i(w + tile_map_coords.x, h + tile_map_coords.y), 1, Vector2i(1,0))
			# cells.erase(Vector2i(w + tile_map_coords.x, h + tile_map_coords.y))
	pass

func place_walls(radius: int) -> void:
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			cells.append(Vector2i(x,y))
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))
