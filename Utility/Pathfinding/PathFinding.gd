extends Node
class_name Pathfinding

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var next_point_in_path: Vector2

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = DungeonGenerator.tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	_get_tile_data()

func get_move_path(current_position: Vector2, end_position: Vector2) -> Array[Vector2i]:
	var id_path: Array[Vector2i]
	if owner.is_moving:
		id_path = astar_grid.get_id_path(
			DungeonGenerator.tile_map.local_to_map(next_point_in_path),
			DungeonGenerator.tile_map.local_to_map(end_position)
		)
	else:
		id_path = astar_grid.get_id_path(
			DungeonGenerator.tile_map.local_to_map(current_position),
			DungeonGenerator.tile_map.local_to_map(end_position)).slice(1)

	if id_path.is_empty() == false:
		current_id_path = id_path
		current_point_path = astar_grid.get_point_path(
			DungeonGenerator.tile_map.local_to_map(current_position),
			DungeonGenerator.tile_map.local_to_map(end_position)
		)
	return id_path

func _get_tile_data() -> void:
	for x in DungeonGenerator.tile_map.get_used_rect().size.x:
		for y in DungeonGenerator.tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + DungeonGenerator.tile_map.get_used_rect().position.x,
				y + DungeonGenerator.tile_map.get_used_rect().position.y
			)
			var tile_data = DungeonGenerator.tile_map.get_cell_tile_data(0, tile_position)
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)
