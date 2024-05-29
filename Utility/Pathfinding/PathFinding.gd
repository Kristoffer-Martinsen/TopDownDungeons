extends Node2D
class_name Pathfinding

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var next_point_in_path: Vector2
var debug_draw_pathfinding = {}

func get_move_path(current_position: Vector2, end_position: Vector2) -> Array[Vector2i]:
	debug_draw_pathfinding[current_position] = end_position
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

func _draw() -> void:
	for key in debug_draw_pathfinding.keys():
		draw_line(key*16, debug_draw_pathfinding[key]*16, Color(Color.RED, 1.0))
	pass

func _process(_delta):
	queue_redraw()
