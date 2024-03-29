extends Node2D

@onready var pathfinding = $"PathFindingComponent"

var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool

const SPEED = 300.0

func _ready() -> void:
	DungeonGenerator.astar_grid = AStarGrid2D.new()
	DungeonGenerator.astar_grid.region = DungeonGenerator.tile_map.get_used_rect()
	DungeonGenerator.astar_grid.cell_size = Vector2(16, 16)
	DungeonGenerator.astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	DungeonGenerator.astar_grid.update()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('DEBUG_restart'):
		get_tree().reload_current_scene()
	if event.is_action_pressed('move') == false:
		return
	#TODO Probably need to refactor this to not take a million params
	current_id_path = pathfinding.get_move_path(is_moving, 
												target_position, 
												get_global_mouse_position(), 
												current_id_path, 
												current_point_path)

func _physics_process(delta: float) -> void:
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		target_position = DungeonGenerator.tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(target_position, 2)
	
	if global_position == target_position:
		current_id_path.pop_front()

		if current_id_path.is_empty() == false:
			target_position = DungeonGenerator.tile_map.map_to_local(current_id_path.front())
		else:
			is_moving = false
