extends Node
class_name Pathfinding

func get_move_path(is_moving: bool, target_position: Vector2, 
					mouse_global_position: Vector2, current_id_path: Array[Vector2i],
					current_point_path: PackedVector2Array) -> Array[Vector2i]:
	var id_path: Array[Vector2i]
	if is_moving:
		id_path = DungeonGenerator.astar_grid.get_id_path(
			DungeonGenerator.astar_grid.local_to_map(target_position),
			DungeonGenerator.astar_grid.local_to_map(mouse_global_position)
		)
	else:
		id_path = DungeonGenerator.astar_grid.get_id_path(
			DungeonGenerator.tile_map.local_to_map(owner.global_position),
			DungeonGenerator.tile_map.local_to_map(mouse_global_position)).slice(1)

	if id_path.is_empty() == false:
		current_id_path = id_path
		current_point_path = DungeonGenerator.astar_grid.get_point_path(
			DungeonGenerator.tile_map.local_to_map(target_position),
			DungeonGenerator.tile_map.local_to_map(mouse_global_position)
		)
	return id_path
