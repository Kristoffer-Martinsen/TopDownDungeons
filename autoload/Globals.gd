extends Node
#
var ASTAR_GRID: AStarGrid2D
var ASTAR_DIMENSIONS: Rect2i = Rect2i(0, 0, 100, 100)

func _ready():
	create_astar2d_grid()

func _get_tile_data() -> void:
	for x in Globals.ASTAR_DIMENSIONS.size.x:
		for y in Globals.ASTAR_DIMENSIONS.size.y:
			var tile_position = Vector2i(
				x + Globals.ASTAR_DIMENSIONS.position.x,
				y + Globals.ASTAR_DIMENSIONS.position.y
			)
			var tile_data = DungeonGenerator.tile_map.get_cell_tile_data(0, tile_position)
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				Globals.ASTAR_GRID.set_point_solid(tile_position)

func create_astar2d_grid():
	ASTAR_GRID = AStarGrid2D.new()
	ASTAR_GRID.region = ASTAR_DIMENSIONS
	ASTAR_GRID.cell_size = Vector2(16, 16)
	ASTAR_GRID.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	ASTAR_GRID.update()
	SignalBus.dungeon_generation_complete.connect(_get_tile_data)
