extends Button

@export var gameScene:PackedScene;

@export var playerEnabled:Array[CheckButton];
@export var playerControlType:Array[Data_Selector];
@export var baseNumberSelect:Data_Selector;
@export var levelSelect:Data_Selector;

# Called when the node enters the scene tree for the first time.
func _ready():
	button_down.connect(_onpress);
	pass # Replace with function body.

func _onpress():
	var playerDict := {}
	var unitList:Array[int] = [];
	
	for playerindex:int in 4:
		if playerEnabled[playerindex].button_pressed:
			var teamName := Global.universalTeamNames[playerindex];
			
			if playerControlType[playerindex].value == 0:
				playerDict[teamName] = "PLAYER";
			else:
				playerDict[teamName] = "AI";
				
			unitList.append(playerindex);
	
	Global.playerDict = playerDict;
	Global.unitList = unitList;
	Global.baseCount = baseNumberSelect.value + 1;
	
	get_tree().change_scene_to_packed(gameScene);
	pass;
