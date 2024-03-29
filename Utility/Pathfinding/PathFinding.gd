extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_move_path(is_moving: bool, 
					target_position: Vector2, 
					mouse_global_position: Vector2, 
					current_id_path: Array[Vector2i],
					current_point_path: PackedVector2Array) -> Array[Vector2i]:
	var id_path: Array[Vector2i]
	if is_moving:
		id_path = Globals.ASTAR_GRID.get_id_path(
			Globals.TILE_MAP.local_to_map(target_position),
			Globals.TILE_MAP.local_to_map(mouse_global_position)
		)
	else:
		id_path = Globals.ASTAR_GRID.get_id_path(
			Globals.TILE_MAP.local_to_map(owner.global_position),
			Globals.TILE_MAP.local_to_map(mouse_global_position)).slice(1)

	if id_path.is_empty() == false:
		current_id_path = id_path
		current_point_path = Globals.ASTAR_GRID.get_point_path(
			Globals.TILE_MAP.local_to_map(target_position),
			Globals.TILE_MAP.local_to_map(mouse_global_position)
		)
	return id_path
