extends Node2D

@onready var pathfinding = $"PathFindingComponent"

var is_moving: bool

const SPEED = 300.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("DEBUG_move"):
		print("player used debug move")
		global_position = get_global_mouse_position()
		print(DungeonGenerator.tile_map.local_to_map(get_global_mouse_position()))
	
	if event.is_action_pressed('DEBUG_restart'):
		get_tree().reload_current_scene()
		#Globals.create_astar2d_grid()
	if event.is_action_pressed('move') == false:
		return
	var path_to_move
	if is_moving:
		path_to_move = pathfinding.get_move_path(
			DungeonGenerator.tile_map.local_to_map(pathfinding.next_point_in_path), 
			DungeonGenerator.tile_map.local_to_map(get_global_mouse_position())
		)
	else:
		path_to_move = pathfinding.get_move_path(
			DungeonGenerator.tile_map.local_to_map(global_position), DungeonGenerator.tile_map.local_to_map(get_global_mouse_position())
		)

func _physics_process(delta: float) -> void:
	if pathfinding.current_id_path.is_empty():
		return
	
	if is_moving == false:
		pathfinding.next_point_in_path = DungeonGenerator.tile_map.map_to_local(pathfinding.current_id_path.front())
		is_moving = true
	
	# Do movement
	global_position = global_position.move_toward(pathfinding.next_point_in_path, 2)
	
	# Update next point in path to move towards
	if global_position == pathfinding.next_point_in_path:
		pathfinding.current_id_path.pop_front()
		if pathfinding.current_id_path.is_empty() == false:
			pathfinding.next_point_in_path = DungeonGenerator.tile_map.map_to_local(pathfinding.current_id_path.front())
		else:
			is_moving = false
