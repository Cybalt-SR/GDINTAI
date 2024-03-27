## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

signal _onWin(teamName:String);

## Resource of type Grid.
@export var grid:Grid
@export var spawnables:Array[PackedScene];

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _active_unit: Unit
var _walkable_cells:Array[Vector2] = [];
var _teams := {};
var _teamscore := {};
var _cur_turn := 0;
var _turn_timer := 0.0;
var _turn_maxtime := 5.0;
var _game_timer := 0.0;
var _game_maxtime := 120.0;

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
			
	for teamName in _teams:
		_teamscore[teamName] = 0;

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
		if(_teams.has(unit.teamName)):
			_teams[unit.teamName].erase(unit);
		
		if(unit.move_range == 0):
			var hasBasesLeft := false;
			for member:Unit in _teams[unit.teamName]:
				if(member.move_range == 0):
					hasBasesLeft = true;
			
			if(hasBasesLeft == false && _teams[unit.teamName].size() > 0):
				for member:Unit in _teams[unit.teamName]:
					_killUnit(member);
				_teams.erase(unit.teamName);
				
				var playerTeamsAlive:Array[String] = [];
				for teamName in _teams:
					for teamunit:Unit in _teams[teamName]:
						if(teamunit.move_range > 0):
							playerTeamsAlive.append(teamName);
							break;
				
				if(playerTeamsAlive.size() == 1):
					_onWin.emit(playerTeamsAlive[0]);
				
		unit.queue_free();

func _get_current_team_turn():
	var counter := 0;
	for	key in _teams:
		if(counter == _cur_turn):
			return key;
		counter += 1;
		
	return "";

func _get_empty() -> Vector2:
	var spawnPos:Vector2 = _walkable_cells.pick_random();
	
	while _get_units_at_cell(spawnPos).size() > 0:
		spawnPos = _walkable_cells.pick_random();
	
	return spawnPos;

func _spawn_spawnable():
	var spawnPos:Vector2 = _get_empty();
	var spawn := spawnables.pick_random().instantiate() as Unit;
	
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
			if(unit.move_range > 0):
				_teamscore[unitToWalk.teamName] += 1;
	
	if(_turn_timer < _turn_maxtime):
		_next_turn();
	
func _next_turn():
	if(_cur_turn == -1):
		return;
	
	if(_active_unit != null && _active_unit._is_walking == true):
		return;
	
	_deselect_active_unit()
	_active_unit = null;
	
	_turn_timer = 0.0;
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
		
func _process(delta):
	if _cur_turn == -1:
		return;
	
	_game_timer += delta;
	_turn_timer += delta;
	
	if(_turn_timer >= _turn_maxtime):
		_next_turn();
	if(_game_timer >= _game_maxtime):
		var winningTeam:String;
		var mostBases := 0;
		
		for teamName in _teams:
			if(teamName == "spawn"):
				continue;
			
			var baseCount := 0;
			for unit:Unit in _teams[teamName]:
				if(unit.move_range == 0):
					baseCount += 1;
			if(baseCount > mostBases):
				winningTeam = teamName;
				mostBases = baseCount;
			elif baseCount == mostBases:
				winningTeam = "";
		
		if(winningTeam.length() == 0):
			var mostScore = 0;
			for teamName in _teams:
				if(teamName == "spawn"):
					continue;
				
				if(_teamscore[teamName] > mostScore):
					winningTeam = teamName;
					mostScore = _teamscore[teamName];
				elif mostScore == _teamscore[teamName]:
					winningTeam = "";
			
		_onWin.emit(winningTeam);
		pass;

func _on__on_win(teamName):
	_cur_turn = -1;
	pass # Replace with function body.
