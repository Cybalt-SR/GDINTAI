@tool
class_name Unit
extends Path2D

signal walk_finished
signal killed(by:Unit);
signal stepover(by:Unit);

var gameBoard:GameBoard;
@export var teamName:String;
@export var grid: Resource
@export var move_range := 6
@export var move_speed := 600.0
@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			await ready
		_sprite.texture = value
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value
@export var lightColor : Color:
	set(value):
		lightColor = value;
		if not _light:
			await ready
		_light.color = value;
@export var lightSize : float:
	set(value):
		lightSize = value;
		if not _light:
			await ready
		_light.texture_scale = value;
@export var bases : Array[Unit]

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO:
	set(value):
		# When changing the cell's value, we don't want to allow coordinates outside
		#	the grid, so we clamp them
		cell = grid.grid_clamp(value)
## Toggles the "selected" animation on the unit.
var is_selected := false:
	set(value):
		is_selected = value
		if is_selected:
			_anim_player.play("selected")
		else:
			_anim_player.play("idle")

var _is_walking := false:
	set(value):
		_is_walking = value
		set_process(_is_walking)

@onready var _light: PointLight2D = $PathFollow2D/PointLight2D
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_process(false)
	_path_follow.rotates = true
	_path_follow.cubic_interp = true

	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()

func goToCell(cellPos:Vector2):
	cell = cellPos
	position = grid.calculate_map_position(cell)

func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta

	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		# Setting this value to 0.0 causes a Zero Length Interval error
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		walk_finished.emit()


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true
