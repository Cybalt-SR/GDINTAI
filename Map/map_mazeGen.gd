extends TileMap

@export var grid:Grid;
@export var generate_on_ready = true
@export var  MAZE_SIZE = Vector2(18,18)
@export var  MAZE_POS = Vector2(1, 1)
@export var WALL_ID = 2
@export var PATH_ID = 1
@export var LIMIT_ID = 3
var tileLayer := 1;

const DIRECTIONS = [
	Vector2.UP * 2,
	Vector2.DOWN * 2,
	Vector2.RIGHT * 2,
	Vector2.LEFT * 2,
]
var current_cell = Vector2.ONE
var visited_cells = [current_cell]
var stack = []

func _ready():
	current_cell += MAZE_POS - Vector2.ONE
	if generate_on_ready:
		generate_maze()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		generate_maze()

### MAZE GENERATION ###

func set_celli(x:int, y:int, id:int):
	if(id == PATH_ID):
		erase_cell(1, Vector2i(x, y));
	else:
		set_cell(1, Vector2i(x, y), id, Vector2i(0,0), id);

func generate_maze():
	#Clear the maze
	visited_cells = [current_cell]
	stack.clear()
	# Create walls
	for x in MAZE_SIZE.x:
		for y in MAZE_SIZE.y:
			set_celli(x+MAZE_POS.x, y+MAZE_POS.y, WALL_ID)
	#create cells
	var cellcount := 0;
	for x in (MAZE_SIZE.x+1)/2:
		for y in (MAZE_SIZE.y + 1)/2:
			set_celli(MAZE_POS.x + 2 * x , MAZE_POS.y + 2 * y, PATH_ID)
			cellcount += 1;
	#get cells
	#generate maze
	while visited_cells.size() < cellcount:
		var neighbours = neighbours_have_not_been_visited(current_cell)
		if neighbours.size() > 0:
			var random_neighbour = neighbours[randi()%neighbours.size()]
			stack.push_front(current_cell)
			var wall = (random_neighbour - current_cell)/2 + current_cell
			set_celli(int(wall.x), int(wall.y), PATH_ID)
			current_cell = random_neighbour
			visited_cells.append(current_cell)
		elif stack.size() > 0:
			current_cell = stack[0]
			stack.pop_front()

func neighbours_have_not_been_visited(cell):
	var neighbours = []
	for dir in DIRECTIONS:
		if !visited_cells.has(cell + dir) && grid.is_within_bounds(cell + dir):
			neighbours.append(cell + dir)
	return neighbours
