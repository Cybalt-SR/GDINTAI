extends Button

@export var gameScene:PackedScene;
@export var mapChoices:Array[PackedScene];

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
			
			var controlType := playerControlType[playerindex];
			var valueIndex := controlType.value;
			playerDict[teamName] = controlType.get_popup().get_item_text(valueIndex);
				
			unitList.append(playerindex);
	
	Global.playerDict = playerDict;
	Global.unitList = unitList;
	Global.baseCount = baseNumberSelect.value + 1;
	Global.mapChoice = mapChoices[levelSelect.value];
	
	get_tree().change_scene_to_packed(gameScene);
	pass;
