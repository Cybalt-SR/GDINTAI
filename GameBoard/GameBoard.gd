## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid:Grid
@export var spawnables:Array[PackedScene];

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _active_unit: Unit
var _walkable_cells:Array[Vector2] = [];
var _teams := {};
var _cur_turn := 0;

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath

func _get_units_at_cell(cell:Vector2) -> Array[Unit]:
	var unitsHere:Array[Unit];
	
	for team in _teams:
		for unit:Unit in _teams[team]:
			if(unit.cell == cell):
				unitsHere.append(unit);
				
	return unitsHere;

func _ready() -> void:
	_reinitialize()

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()

func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning

## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	var worldPos = grid.calculate_map_position(cell);
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(worldPos + grid._half_cell_size, worldPos)
	var result = space_state.intersect_ray(query)
	if result:
		return true;
		
	return false;

func _updateWalkables():
	_walkable_cells.clear();
	
	for x in grid.size.x:
		for y in grid.size.y:
			var curPos := Vector2(x,y);
			if(grid.is_within_bounds(curPos) && !is_occupied(curPos)):
				_walkable_cells.append(curPos);
	
	_unit_path.initialize(_walkable_cells);

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_updateWalkables();
	_teams.clear();
	
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		var alrAdded := false;
		for teamName in _teams:
			if(teamName == unit.teamName):
				_teams[teamName].append(unit);
				alrAdded = true;
				
		if(alrAdded == false):
			_teams[unit.teamName] = [unit];

func _killUnit(unit:Unit):
	var validRespawnPoints:Array[Unit];
	
	for base:Unit in unit.bases:
		if(is_instance_valid(base) && base.cell != unit.cell && _teams[unit.teamName].has(base)):
			validRespawnPoints.append(base);
	
	if(validRespawnPoints.size() > 0):
		var randomChoice:int = randi_range(0, validRespawnPoints.size() - 1);
		var chosenBase := validRespawnPoints[randomChoice];
		unit.cell = chosenBase.cell;
		unit.position = grid.calculate_map_position(chosenBase.cell);
	else:
		_teams[unit.teamName].erase(unit);
		
		if(unit.move_range == 0):
			var hasBasesLeft := false;
			for member:Unit in _teams[unit.teamName]:
				if(member.move_range == 0):
					hasBasesLeft = true;
			
			if(hasBasesLeft == false && _teams[unit.teamName].size() > 0):
				for member:Unit in _teams[unit.teamName]:
					_killUnit(member);
					
		unit.queue_free();

func _get_current_team_turn():
	var counter := 0;
	for	key in _teams:
		if(counter == _cur_turn):
			return key;
		counter += 1;

func _spawn_spawnable():
	var spawn := spawnables.pick_random().instantiate() as Unit;
	
	var spawnPos:Vector2 = _walkable_cells.pick_random();
	
	while _get_units_at_cell(spawnPos).size() > 0:
		spawnPos = _walkable_cells.pick_random();
	
	spawn.teamName = "spawn";
	spawn.gameBoard = self;
	spawn.grid = grid;
	spawn.cell = spawnPos;
	spawn.position = grid.calculate_map_position(spawnPos);
	
	if(_teams.has(spawn.teamName)):
		_teams[spawn.teamName].append(spawn);
	else:
		_teams[spawn.teamName] = [spawn];
	
	add_child(spawn);
	return spawn;

## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit() -> void:
	if(_unit_path.current_path.size() == 0):
		return;
		
	var new_cell := _unit_path.current_path[-1];
	
	if _active_unit.cell == new_cell:
		_deselect_active_unit()
		return
	# warning-ignore:return_value_discarded
	
	var unitToWalk := _active_unit;
	_deselect_active_unit()
	
	unitToWalk.walk_along(_unit_path.current_path)
	await unitToWalk.walk_finished
	_active_unit = null;
	new_cell = unitToWalk.cell;
	
	var unitsHere = _get_units_at_cell(new_cell);
	for unit:Unit in unitsHere:
		if unit.teamName != unitToWalk.teamName:
			_killUnit(unit);
	
	var foundValidTurner := false;
	while !foundValidTurner:
		_cur_turn += 1;
		_cur_turn %= _teams.size();
		
		if(_cur_turn == 0):
			_spawn_spawnable();
		
		foundValidTurner = _teams[_get_current_team_turn()].size() > 0;
		if(_get_current_team_turn() == "spawn"):
			foundValidTurner = false;
			

## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_unit_overlay.clear()
	_unit_path.stop()

## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		var unitsHere := _get_units_at_cell(cell);
		if unitsHere.size() == 0:
			return
		
		for	unitHere:Unit in unitsHere:
			if(unitHere.move_range < 1):
				continue;
				
			if _get_current_team_turn() != unitHere.teamName:
				continue;

			_updateWalkables();
			
			_active_unit = unitHere
			return;
	elif(_active_unit._is_walking == false):
		_move_active_unit()


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit && !_active_unit._is_walking:
		_unit_path.draw(_active_unit.cell, new_cell, _active_unit.move_range)
