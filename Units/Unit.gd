@tool
class_name Unit
extends Path2D

signal walk_finished
signal killed(by:Unit);
signal stepover(by:Unit);

var gameBoard:GameBoard;
@export var targetPriorityMod:float = 1;
@export var targetPriorityMod_attack:float = 0;
@export var targetPriorityMod_defend:float = 0;
@export var teamName:String;
@export var grid: Grid
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
		cell = grid.grid_clamp(value)
var _is_walking := false;
var _timeInvulnerable := 0.0;

@onready var _light: PointLight2D = $PathFollow2D/PointLight2D
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var _shield_collider: CollisionShape2D = $StaticBody2D/CollisionShape2D;
@onready var _shield_icon: Sprite2D = $StaticBody2D/CollisionShape2D/Sprite;

func _ready() -> void:
	_path_follow.rotates = true
	_path_follow.cubic_interp = true

	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()

func _process(delta: float) -> void:
	_timeInvulnerable -= delta;
	
	if(_shield_collider != null && _shield_icon != null):
		_shield_collider.disabled = _timeInvulnerable <= 0;
		_shield_icon.set_visible(!_shield_collider.disabled);
	
	if(_is_walking):
		_path_follow.progress += move_speed * delta
		
		var curGridPos := grid.calculate_grid_coordinates(_path_follow.global_position);
		for stepon:Unit in gameBoard._get_units_at_cell(curGridPos):
			stepon.stepover.emit(self);
		
		if _path_follow.progress_ratio >= 1.0:
			_is_walking = false
			# Setting this value to 0.0 causes a Zero Length Interval error
			position = grid.calculate_map_position(cell);
			_path_follow.progress = 0.00001
			curve.clear_points()
			walk_finished.emit()



## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return
	
	cell = path[-1];
	
	curve.clear_points();
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	_path_follow.progress = 0.0001;
	_is_walking = true
