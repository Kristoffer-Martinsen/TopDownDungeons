extends Node2D

@onready var tile_map = $"../Dungeon/TileMap"
@onready var pathfinding = $"PathFindingComponent"

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool

const SPEED = 300.0

func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	Globals.ASTAR_GRID = astar_grid

	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

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
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(target_position, 2)
	
	if global_position == target_position:
		current_id_path.pop_front()

		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else:
			is_moving = false
