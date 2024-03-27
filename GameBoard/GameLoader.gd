extends Node2D

@export var playerSkin:Texture2D;
@export var baseSkin:Texture2D;
@export var unitfab:PackedScene;
@export var AIfab:PackedScene;
@export var gameBoard:GameBoard;
@export var map:TileMap;

var _teamColors := {};
var _teamControl := {};
var _spawnableNodes: Array[Vector2];

var loadedin := false;
var isEvE := false;

func _ready():
	var twoplayerdict := {
	"0": "PLAYER",
	"1": "PLAYER",
	}
	var fourAIdict := {
	"0": "AI",
	"1": "AI",
	"2": "AI",
	"3": "AI",
	}
	var oneVoneList:Array[int] = [0,1]
	var freeFourAllList:Array[int] = [0,1,2,3]
	var universalColorCode :={
	"0": Color.GREEN,
	"1": Color.RED * 3,
	"2": Color.AQUAMARINE * 2,
	"3": Color.BLUE * 2,
	}
	
	#_InitGame(twoplayerdict, universalColorCode, oneVoneList, 5);
	_InitGame(fourAIdict, universalColorCode, freeFourAllList, 5);	

func _pop_pos(from:Array[Vector2]) -> Vector2:
	var randomIndex := randi_range(0, from.size() - 1);
	var newPos:Vector2 = from[randomIndex];
	from.remove_at(randomIndex);
	return newPos;

func _spawnBase(team:String, pos:Vector2) -> Unit:
	var instance := unitfab.instantiate() as Unit;
	
	instance.gameBoard = gameBoard;
	instance.teamName = team;
	instance.lightColor = _teamColors[team];
	instance.position = gameBoard.grid.calculate_map_position(pos);
	
	instance.skin = baseSkin;
	instance.move_range = 0;
	instance.lightSize = 4;
	
	gameBoard.add_child(instance);
	return instance;

func _spawnPlayer(team:String, pos:Vector2, bases:Array[Unit]):
	var instance := unitfab.instantiate() as Unit;
	
	instance.gameBoard = gameBoard;
	instance.teamName = team;
	instance.lightColor = _teamColors[team];
	instance.position = gameBoard.grid.calculate_map_position(pos);

	instance.skin = playerSkin;
	instance.move_range = 7;
	instance.move_speed = 1000;
	
	instance.z_index = 1;
	instance.bases = bases;
	
	if(_teamControl[team] == "PLAYER" || isEvE):
		instance.lightSize = 8;
	
	gameBoard.add_child(instance);
	
func _spawnAI(team:String):
	var instance := AIfab.instantiate() as UnitAI;
	
	instance.teamName = team;
	instance.gameBoard = gameBoard;
	
	add_child(instance);

func _InitGame(teamControl:Dictionary, teamColors:Dictionary, playerList:Array[int], baseCount:int):
	isEvE = true;
	
	for controllerIndex in teamControl:
		if(teamControl[controllerIndex] == "PLAYER"):
			isEvE = false;
	
	await get_tree().create_timer(1.0).timeout
	
	gameBoard._reinitialize();

	_teamColors = teamColors;
	_teamControl = teamControl;
	_spawnableNodes = gameBoard._walkable_cells.duplicate();
	
	var teamIndex := 0;
	for teamName in teamControl:
		var bases:Array[Unit] = [];
		var basePoses:Array[Vector2] = [];
		
		for i_base in baseCount:
			var basePos := _pop_pos(_spawnableNodes);
			basePoses.append(basePos);
			var newBase := _spawnBase(teamName, basePos);
			bases.append(newBase);
			
		for player in playerList:
			if(player == teamIndex && basePoses.size() > 0):
				_spawnPlayer(teamName, _pop_pos(basePoses), bases);
		
		if(_teamControl[teamName] == "AI"):
			_spawnAI(teamName);
		
		teamIndex += 1;
	
	gameBoard._reinitialize();
	
	pass;
