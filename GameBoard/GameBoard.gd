## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


## Resource of type Grid.
@export var grid:Grid

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells:Array[Vector2] = [];
var _teams:Array[Array];
var _cur_turn := 0;

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath

func _ready() -> void:
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


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


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_walkable_cells.clear();
	
	for x in grid.size.x:
		for y in grid.size.y:
			var curPos := Vector2(x,y);
			if(grid.is_within_bounds(curPos) && !is_occupied(curPos)):
				_walkable_cells.append(curPos);
	
	_unit_path.initialize(_walkable_cells)
	
	_units.clear()
	_teams.clear();
	
	
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		var alrAdded := false;
		for team:Array[Unit] in _teams:
			if(team[0].teamName == unit.teamName):
				team.append(unit);
				alrAdded = true;
				
		if(alrAdded == false):
			_teams.append([unit]);
			
		_units[unit.cell] = [unit]

#returns true if it successfully eliminated something
func standOnCell(new_cell: Vector2):
	var toRemove:Array[Unit];
	var displacedSmth := false;
	
	if(_units.has(new_cell)):
		for unitHere:Unit in _units[new_cell]:
			if(unitHere == _active_unit):
				continue;
			toRemove.append(unitHere);
	
	for	removee:Unit in toRemove:
		if(_active_unit.bases.has(removee)):
			continue;
		
		_units[new_cell].erase(removee);
		var validRespawnPoints:Array[Unit];
		
		for base:Unit in removee.bases:
			if(is_instance_valid(base)):
				validRespawnPoints.append(base);
		
		if(validRespawnPoints.size() > 0):
			var randomChoice:int = randi_range(0, validRespawnPoints.size() - 1);
			var chosenBase := validRespawnPoints[randomChoice];
			removee.goToCell(chosenBase.cell);
			_units[chosenBase.cell].append(removee);
		else:
			removee.free();
			
		displacedSmth = true;

	if(toRemove.size() > 0):
		return displacedSmth;

## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells or _active_unit.cell == new_cell:
		_deselect_active_unit()
		_clear_active_unit()
		return
	# warning-ignore:return_value_discarded
		
	_units[_active_unit.cell].erase(_active_unit)
	if(_units[_active_unit.cell].size() == 0):
		_units.erase(_active_unit.cell);
	
	if(_units.has(new_cell)):
		_units[new_cell].append(_active_unit)
	else:
		_units[new_cell] = [_active_unit]
	
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	
	while(standOnCell(new_cell)):
		pass;
	
	_clear_active_unit()
	_cur_turn += 1;
	_cur_turn %= _teams.size();

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	
	for	unitHere:Unit in _units[cell]:
		if(unitHere.move_range < 1):
			continue;
			
		if _teams[_cur_turn][0].teamName != unitHere.teamName:
			continue;

		_active_unit = unitHere
		_active_unit.is_selected = true
		_unit_overlay.draw(_walkable_cells)
		
		return;


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell, _active_unit.move_range)
