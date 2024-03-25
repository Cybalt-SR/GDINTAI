## Draws the unit's movement path using an autotile.
class_name UnitPath
extends TileMap

@export var grid: Resource

var _pathfinder: PathFinder
var current_path := PackedVector2Array()


## Creates a new PathFinder that uses the AStar algorithm to find a path between two cells among
## the `walkable_cells`.
func initialize(walkable_cells: Array) -> void:
	current_path.clear();
	_pathfinder = PathFinder.new(grid, walkable_cells)


## Finds and draws the path between `cell_start` and `cell_end`
func draw(cell_start: Vector2, cell_end: Vector2, range:int) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path_bound(cell_start, cell_end, range)
	set_cells_terrain_connect(0, current_path, 0, 0)


## Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	clear()
