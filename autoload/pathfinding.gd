extends Node2D

var astar_grid: AStar2D
var tile_map: TileMap
var is_moving: bool
var target_position: Vector2
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array

# TODO Change this from a Pathfinding autoload to a pathfinding reusable component.
# TODO The creation of the astar grid can probably be a autoload singelton. 

func initialize_astar_grid(w: int, h: int) -> void:
  astar_grid = AStar2D.new()
  astar_grid.region = Rect2i(Vector2.ZERO, Vector2(w, h)) #Do you need the tilemap?
  astar_grid.cell_size = Vector2(16, 16)
  astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
  astar_grid.update()
  for x in astar_grid.region.size.x:
    for y in astar_grid.region.size.y:
      var tile_position = Vector2i(
        x + astar_grid.region.position.x,
        y + astar_grid.region.position.y
      )
      var tile_data = tile_map.get_cell_tile_data(0, tile_position)

      if tile_data == null or tile_data.get_custom_data("walkable") == false:
        astar_grid.set_point_solid(tile_position)

func get_astar_path(current_pos: Vector2, target_pos: Vector2) -> void:
  var id_path
  if is_moving:
    id_path = astar_grid.get_id_path(
      tile_map.local_to_map(target_position), 
      tile_map.local_to_map(get_global_mouse_position()))
  else:
    id_path = astar_grid.get_id_path(
      tile_map.local_to_map(global_position), 
      tile_map.local_to_map(get_global_mouse_position())).slice(1)

  if id_path.is_empty() == false:
    current_id_path = id_path
    current_point_path = astar_grid.get_point_path(
      tile_map.local_to_map(target_position), 
      tile_map.local_to_map(get_global_mouse_position()))

func set_tile_map(tile_map_to_set: TileMap) -> void:
  tile_map = tile_map_to_set