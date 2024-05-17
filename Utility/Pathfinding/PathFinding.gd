extends Node
class_name Pathfinding

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var next_point_in_path: Vector2

func get_move_path(current_position: Vector2, end_position: Vector2) -> Array[Vector2i]:
	var id_path: Array[Vector2i]
	id_path = Globals.ASTAR_GRID.get_id_path(
		current_position, end_position
	)
	if id_path.is_empty() == false:
		current_id_path = id_path
		current_point_path = Globals.ASTAR_GRID.get_point_path(
			current_position, end_position
		)
	return id_path
